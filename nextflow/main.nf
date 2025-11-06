#!/usr/bin/env nextflow

process summarise {
    publishDir "${params.outdir}", mode: 'copy'
    container 'ghcr.io/zwets/hamronization:1.1.10'
    cpus 1

    input:
    path inputs

    output:
    path('report.tsv')
    path('report.json')
    path('report.html')

    script:
    """
    hamronize summarize -t tsv -o report.tsv $inputs
    hamronize summarize -t json -o report.json $inputs
    hamronize summarize -t interactive -o report.html $inputs
    """
}

process hamronize {
    publishDir "${params.outdir}", mode: 'copy'
    container 'ghcr.io/zwets/hamronization:1.1.10'
    cpus 1

    input:
    tuple val(id), val(tool), path(metadata), path(results)

    output:
    path "${id}-${tool}.tsv"

    script:
    """
    METADATA=\$(cat $metadata)
    hamronize $tool \$METADATA $results >'${id}-${tool}.tsv'
    """
}

process amrfinderplus {
    container 'docker.io/ncbi/amr:4.0.23-2025-07-16.1'
    cpus 4

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('amrfinderplus'), path('metadata.txt'), path('amrfinderplus.tsv')

    script:
    """
    # Set species to have AFP's required underscore instead of space then set SPECIES_OPT iff SPECIES is supported by AFP
    SPECIES=`echo '$species' | sed -e 's/ /_/g'`
    [ -n "\$SPECIES" ] && amrfinder --list_organisms 2>/dev/null | fgrep -q "\$SPECIES" && SPECIES_OPT="-O \$SPECIES" || SPECIES_OPT=''

    # Run AFP
    amrfinder -n $contigs \$SPECIES_OPT -o amrfinderplus.tsv --threads ${task.cpus}

    # Produce metadata.txt
    DB_VER=`amrfinder -V | fgrep 'Database version:' | cut -d':' -f2`
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `amrfinder -v` \$DB_VER >metadata.txt
    """
}

process resfinder {
    container 'docker.io/genomicepidemiology/resfinder:4.7.2'
    containerOptions '--entrypoint ""'
    cpus 2

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('resfinder'), path('metadata.txt'), path('resfinder.json')

    script:
    """
    touch metadata.txt # Leave empty as ResFinder writes all required metadata in its JSON output
    python -m resfinder --acquired --point --disinfectant --species '$species' --ignore_missing_species -ifa $contigs -j resfinder.json -o . --kma_threads ${task.cpus}
    """
}

process rgi {
    container 'quay.io/biocontainers/rgi:6.0.5--pyh05cac1d_0'
    cpus 8

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('rgi'), path('metadata.txt'), path('rgi.txt')

    script:
    """
    rgi main -i $contigs -o rgi -n ${task.cpus} --clean
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `rgi main --version` `rgi database --version` >metadata.txt
    """
}

workflow {

    // Parse the sample sheet into a channel of (id, species, assembly) tuples and connect to the tools in parallel
    Channel.fromPath(params.input).splitCsv(header: true, sep: '\t')  // boycott CSV!
        | map { row -> tuple(row.id, row.species, file(row.assembly)) }
        | (amrfinderplus & resfinder & rgi)

    // Pull the tool outputs into a single channel, harmonise each, collect all harmoniseds, and summarise overall
    Channel.of().mix(amrfinderplus.out, resfinder.out, rgi.out)
        | hamronize 
        | collect // into array
        | summarise

}


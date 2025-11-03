#!/usr/bin/env nextflow

process summarize {
    publishDir "${params.outdir}", mode: 'copy'
    conda 'hamronization=1.1.9'
    cpus 1

    input:
    path inputs

    output:
    path('report.tsv'), emit: tsv
    path('report.json'), emit: json
    path('report.html'), emit: html

    script:
    """
    hamronize summarize -t tsv -o report.tsv $inputs
    hamronize summarize -t json -o report.json $inputs
    hamronize summarize -t interactive -o report.html $inputs
    """
}

process hamronize {
    publishDir "${params.outdir}", mode: 'copy'
    conda 'hamronization=1.1.9'
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
    container 'localhost/amrfinderplus:4.0.23'
    cpus 4

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('amrfinderplus'), path('metadata.txt'), path('amrfinderplus.tsv')

    script:
    """
    # Set species to have AFP's required underscore instead of space then set SPECIES_OPT iff SPECIES is supported by AFP
    SPECIES=`echo '$species' | sed -e 's/ /_/g'`
    [ -n "\$SPECIES" ] && amrfinderplus --list_organisms 2>/dev/null | fgrep -q "\$SPECIES" && SPECIES_OPT="-O \$SPECIES" || SPECIES_OPT=''

    # Run AFP
    amrfinderplus -n $contigs \$SPECIES_OPT -o amrfinderplus.tsv --threads ${task.cpus}

    # Produce metadata.txt
    DB_VER=`amrfinderplus -V | fgrep 'Database version:' | cut -d':' -f2`
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `amrfinderplus -v` \$DB_VER >metadata.txt
    """
}

process resfinder {
    container 'localhost/resfinder:4.7.2'
    cpus 2

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('resfinder'), path('metadata.txt'), path('resfinder.json')

    script:
    """
    touch metadata.txt # Leave empty as ResFinder writes all required metadata in its JSON output
    resfinder --acquired --point --disinfectant --species '$species' --ignore_missing_species -ifa $contigs -j resfinder.json -o . --kma_threads ${task.cpus}
    """
}

process rgi {
    container 'localhost/rgi:6.0.5'
    cpus 8

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('rgi'), path('metadata.txt'), path('rgi.txt')

    script:
    """
    run-rgi --input_sequence $contigs --output_file rgi --num_threads ${task.cpus}
    rm -rf localDB || true
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `rgi main --version` `rgi database --version` >metadata.txt
    """
}

workflow {

    // Parse the sample sheet into a channel of (id, species, assembly) tuples and connect to the tools in parallel
    Channel.fromPath(params.input).splitCsv(header: true, sep: '\t')  // boycott CSV!
        | map { row -> tuple(row.id, row.species, file(row.assembly)) }
        | (amrfinderplus & resfinder & rgi)

    // Pull the tool outputs into a single channel, harmonise each, collect all harmoniseds, and summarize overall
    Channel.of().mix(amrfinderplus.out, resfinder.out, rgi.out)
        | hamronize 
        | collect // into array
        | summarize

}


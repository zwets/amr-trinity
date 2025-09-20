#!/usr/bin/env nextflow

include { samplesheetToList } from 'plugin/nf-schema'

process hamronize {
    conda 'hamronization=1.1.9'
    cpus 1

    input:
    tuple val(tool), path(results), path(metadata)

    output:
    path 'hamronized.tsv'

    script:
    """
    METADATA="$(cat $metadata)"
    hamronize $tool \$METADATA $results >'hamronized.tsv'
    """
}

process amrfinderplus {
    container 'localhost/amrfinderplus:4.0.23'
    cpus 4

    input:
    tuple val(id), val(species), path(contigs)

    output:
    path 'amrfinderplus.tsv'
    path 'metadata.txt'

    script:
    """
    [ -n '$species' ] && amrfinder --list_organisms /database 2>/dev/null | fgrep -q '$species' && SPECIES_OPT='-O $species' || SPECIES_OPT=''
    amrfinderplus -n $contigs \$SPECIES_OPT -o amrfinderplus.tsv --threads ${task.cpus} |&
        sed -En 's/^Software version: (.*)\$/--analysis_software_version \\1/p;s/^Database version: (.*)\$/--reference_database_version \\1/p' |
        sort -u | tr '\\n' ' ' >metadata.txt
    """
}

process resfinder {
    container 'localhost/resfinder:4.7.2'
    cpus 2

    input:
    tuple val(id), val(species), path(contigs)

    output:
    path 'resfinder.json'
    path 'metadata.txt'

    script:
    """
    resfinder --acquired --point --disinfectant --species '$species' --ignore_missing_species -ifa $contigs -j resfinder.json -o . --kma_threads ${task.cpus}
    touch metadata.txt
    """
}

process rgi {
    container 'localhost/rgi:6.0.5'
    cpus 8

    input:
    tuple val(id), val(species), path(contigs)

    output:
    path 'rgi.txt'
    path 'metadata.txt'

    script:
    """
    run-rgi --input_sequence $contigs --output_file rgi --num_threads ${task.cpus}
    rm -rf localDB || true
    printf -- '--analysis_software_version %s --reference_database_version %s\\n' \$(rgi main --version) \$(jq -r '._version' rgi.json) >metadata.txt
    """
}

workflow {
    // Parse the sample sheet into a channel of (id, species, assembly) tuples
    ch_input = Channel.fromList(samplesheetToList(params.input, 'schema.json'))
        | map { id, species, assembly -> tuple(id, species, file(assembly)) } // convert string to path

    ch_input | (rgi & resfinder & amrfinderplus)
}


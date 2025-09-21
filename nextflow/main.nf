#!/usr/bin/env nextflow

include { samplesheetToList } from 'plugin/nf-schema'

process summarize {
    publishDir "${params.outdir}"
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
    printf -- '--input_file_name ${contigs.name} ' >metadata.txt
    [ -n '$species' ] && amrfinder --list_organisms /database 2>/dev/null | fgrep -q '$species' && SPECIES_OPT='-O $species' || SPECIES_OPT=''
    amrfinderplus -n $contigs \$SPECIES_OPT -o amrfinderplus.tsv --threads ${task.cpus} 2>stderr.log
    # We grep the metadata (program and database version) from stderr
    sed -En 's/^Software version: (.*)\$/--analysis_software_version \\1/p;s/^Database version: (.*)\$/--reference_database_version \\1/p' stderr.log | sort -u | tr '\\n' ' ' >>metadata.txt
    """
}

process resfinder {
    container 'localhost/resfinder:4.7.2'
    cpus 2

    input:
    tuple val(id), val(species), path(contigs)

    output:
    //path 'resfinder.json', emit: results
    //path 'metadata.txt', emit: metadata
    tuple val(id), val('resfinder'), path('metadata.txt'), path('resfinder.json')

    script:
    """
    touch metadata.txt
    resfinder --acquired --point --disinfectant --species '$species' --ignore_missing_species -ifa $contigs -j resfinder.json -o . --kma_threads ${task.cpus}
    """
}

process rgi {
    container 'localhost/rgi:6.0.5'
    cpus 8

    input:
    tuple val(id), val(species), path(contigs)

    output:
    //path 'rgi.txt', emit: results
    //path 'metadata.txt', emit: metadata
    tuple val(id), val('rgi'), path('metadata.txt'), path('rgi.txt')

    script:
    """
    run-rgi --input_sequence $contigs --output_file rgi --num_threads ${task.cpus}
    rm -rf localDB || true
    printf -- '--input_file_name %s --analysis_software_version %s --reference_database_version %s' ${contigs.name} \$(rgi main --version) \$(rgi database --version) >metadata.txt
    """
}

workflow {

    // Parse the sample sheet into a channel of (id, species, assembly) tuples and connect to the tools in parallel
    Channel.fromList(samplesheetToList(params.input, 'schema.json'))
        | map { id, species, assembly -> tuple(id, species, file(assembly)) } // convert string to path
        | (amrfinderplus & resfinder & rgi)

    // Join the output of the tools into a single channel and feed into hamronization process
    amrfinderplus.out.mix(resfinder.out, rgi.out)
        | hamronize 
        | collect
        | summarize

}


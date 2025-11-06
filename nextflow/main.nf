#!/usr/bin/env nextflow

include { amrfinderplus } from './modules/amrfinderplus.nf'
include { resfinder } from './modules/resfinder.nf'
include { rgi } from './modules/rgi.nf'

// Final summary of the three tools across all isolates
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

// Harmonizes the per tool per sample output
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


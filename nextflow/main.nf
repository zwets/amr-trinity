#!/usr/bin/env nextflow

// Default params, override with --input ..., --outdir ...
params {
    input = 'test/mini/isolates.tsv'
    outdir = 'results'
}

// Include the modules with the Big Three
include { amrfinderplus } from './modules/amrfinderplus.nf'
include { resfinder } from './modules/resfinder.nf'
include { rgi } from './modules/rgi.nf'

// Final summary of the three tools across all isolates
process summarise {
    publishDir "${params.outdir}", mode: 'copy'

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

// Hamronize the per tool per sample output
process hamronize {
    publishDir "${params.outdir}", mode: 'copy'

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

    // Strip comments and empty lines from the input sample sheet to humour splitCsv with clean TSV input
    samplesheet = Channel.fromPath(params.input).splitText().filter { s -> ! (s.strip() ==~ /^\s*(#.*)?$/) }
        | collectFile(name: 'samplesheet.tsv', sort: false)

    // Parse the sample sheet into a channel of (id, species, assembly) tuples and connect to the tools in parallel
    samplesheet.splitCsv(header: true, sep: '\t')  // boycott CSV!
        | map { row -> tuple(row.id, row.species, file(row.assembly)) }
        | (amrfinderplus & resfinder & rgi)

    // Pull the tool outputs into a single channel, harmonise each, collect all harmoniseds, and summarise overall
    Channel.of().mix(amrfinderplus.out, resfinder.out, rgi.out)
        | hamronize
        | collect // into array
        | summarise

}


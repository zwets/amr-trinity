# AMR Trinity - Nextflow workflow

This is the "AMR Trinity" workflow implemented in Nextflow.


## Installation

Install Nextflow as documented on [their site](https://www.nextflow.io/docs/latest/getstarted.html)

In the directory where you read this README.md, run smoke test

    nextflow main.nf

If all went well you will find the results in the `results` directory.


## Usage

The workflow requires that your assemblies are listed in a "sample sheet"
(same as for the Snakemake workflow), a TSV with at least:

 * `id`: the identifier by which the workflow should refer to the isolate
 * `species`: name of the species of the isolate, may be empty or `Unknown`
 * `assembly`: path to the FASTA file with the assembled contigs

Once you have the sample sheet, invoke the workflow as above:

    ./main.nf --input path/to/isolates.tsv --output path/to/results

By default the aggregate hAMRonised results are written into `./results/`.

To run with different config settings see [nextflow.config](nextflow.config).

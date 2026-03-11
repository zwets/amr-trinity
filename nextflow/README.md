# AMR Trinity - Nextflow workflow

This is the "AMR Trinity" workflow implemented in Nextflow, with
profiles to run with Apptainer (Singularity), Podman or Docker.


## Installation

Install Nextflow as documented on [their site](https://www.nextflow.io/docs/latest/getstarted.html)

In the directory where you read this README.md, run smoke test

    nextflow main.nf                   # standard profile = podman
    nextflow -profile docker main.nf   # pick your profile

or simply

    ./main.nf
    ./main.nf -profile apptainer

These run the workflow on data from `test/mini` and write outputs to
directories `./results` and `./benchmark`, taking configuration from
`./nextflow.config`.


## Usage

The workflow requires that your assemblies are listed in a "sample sheet"
(same as for the Snakemake workflow), a TSV with at least these columns:

 * `id`: the identifier by which the workflow should refer to the isolate
 * `species`: name of the species of the isolate, may be empty or `Unknown`
 * `assembly`: path to the FASTA file with the assembled contigs

To run the workflow, specify the path to the sample sheet as input

    ./main.nf --input path/to/isolates.tsv

You will also want to override the output directory (default `./results`)

    ./main.nf --input path/to/isolates.tsv --output path/to/resultdir

To run with different config settings see [nextflow.config](nextflow.config).

# AMR Trinity - Nextflow workflow

This is the "AMR Trinity" workflow implemented in Nextflow, with
profiles to run with Apptainer (Singularity), Podman or Docker.


## Installation

Install Nextflow as documented on [their site](https://www.nextflow.io/docs/latest/getstarted.html)

In the directory where you read this README.md, run smoke test

    # Pick your profile: apptainer, docker, podman, singularity
    nextflow main.nf -profile apptainer

or simply

    ./main.nf -profile apptainer

This runs the workflow on data from `test/mini` and writes outputs to
directories `./results` and `./benchmarks`.  It takes these defaults
from `main.nf` and `nextflow.config`.

**Tip**
To spare yourself from typing `-profile yourprofile` add the desired
container runtime to the `standard` profile in `nextflow.config`.


## Usage

The workflow requires that your assemblies are listed in a "sample sheet"
(same as for the Snakemake workflow), a TSV with at least these columns:

 * `id`: the identifier by which the workflow should refer to the isolate
 * `species`: name of the species of the isolate, may be empty or `Unknown`
 * `assembly`: path to the FASTA file with the assembled contigs

To run the workflow, specify the path to the sample sheet as input

    ./main.nf --input path/to/isolates.tsv

You may also want to override the output directory (default `./results`)

    ./main.nf --input path/to/isolates.tsv --outdir path/to/resultdir

A Slurm profile has been provided as well.  To run with this:

    ./main.nf -profile slurm,apptainer

Or, forgoing predefined profiles:

    ./main.nf -process.executor slurm -with-apptainer

To run with different config settings see [nextflow.config](nextflow.config).


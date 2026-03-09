# AMR Trinity - Snakemake with Apptainer

This is essentially the same workflow as "Snakemake with Conda", except that
instead of Conda environments we use Docker versions of the Big Three.

> **Note:** in the workflow we use the upstream releases of the tools, i.e.
> those produced by the Big Three teams themselves.  Alternatively you may
> find images in the _Biocontainers registry_, which provides Dockerised
> versions of the Conda packages in the _Bioconda project_.

We assume that you have `snakemake` (9.16) available as you did for running
the [snakemake-conda](../snakemake-conda) workflow.  We use the same sample
sheet format as described there.


## Usage

The $[default profile](profiles/default/config.yaml) sets the required
command-line parameters:

    cores: all
    software-deployment-method: apptainer
    benchmark-extended: true

Invoke the workflow with config parameter `samples` set to the sample sheet:

    snakemake -C samples=path/to/isolates.tsv

Outputs are the same as described in the
[snakemake-conda README](../snakemake-conda/README.md), though results may
differ due to version differences between the Conda and Docker releases of
the tools.

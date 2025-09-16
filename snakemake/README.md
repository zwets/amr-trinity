# AMR Trinity - Snakemake workflow

This workflow is a scaled down and simplified version of the Snakemake workflow
in [hAMRonization Workflow](https://github.com/pha4ge/hAMRonization_workflow.git).


## Installation

Install prerequisites for building this pipeline (on Ubuntu):

    sudo apt install git # build-essential git zlib1g-dev curl wget file jq

Create the Conda environment

    conda env create -n amr-trinity --file workflow/envs/amr-trinity.yaml

Run a smoke test (this takes a while as Snakemake pulls tools and databases)

    conda activate amr-trinity
    snakemake --configfile test/mini/config.yaml --use-conda --cores 1

Rerun the last command.  It should report "Nothing to be done" in seconds


## Use

Create the sample sheet

    # TODO

Point the config file at the sample sheet

    # TODO

Run

    # TODO

Remember to always put `--use-conda` on the command-line.  Snakemake's error
reporting will not make it in any way clear that you didn't.

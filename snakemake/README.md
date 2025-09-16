# AMR Trinity - Snakemake workflow

This workflow is a scaled down and simplified version of the Snakemake workflow
in [hAMRonization Workflow](https://github.com/pha4ge/hAMRonization_workflow.git).


## Installation

Create Conda environment *amr-trinity*

    conda env create -n amr-trinity -f workflow/envs/amr-trinity.yaml

Activate and run smoke test (will take a while as it pull the tools!)

    conda activate amr-trinity
    snakemake --configfile test/mini/config.yaml --sdm conda --cores 1

If you rerun the last command it should report "Nothing to be done".


## Use

Create the sample sheet

    # TODO

Point the config file at the sample sheet

    # TODO

Run

    # TODO

Remember to always put `--use-conda` on the command-line.  Snakemake's error
reporting will not make it in any way clear that you didn't.

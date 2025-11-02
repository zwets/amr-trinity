# AMR Trinity - Snakemake workflow

This workflow is a scaled down and simplified version of the Snakemake workflow
in [hAMRonization Workflow](https://github.com/pha4ge/hAMRonization_workflow.git).

> ResFinder and RGI can process reads, but AMRFinderPlus only works with assemblies,
> which is why the workflow is defined only for FASTA inputs.


## Installation

Create Conda environment *snakemake*

    conda env create -n snakemake -f workflow/envs/snakemake.yaml

Activate the environment

    conda activate snakemake

Run the smoke test on the NDM mini sample (this will take a while, as tools
and databases are getting installed)

    snakemake --cores all --sdm conda -C samples=test/mini/isolates.tsv

If all went well you will find the results in the `results` directory.


## Usage

The workflow requires that your assemblies are listed in a "sample sheet".
This is a TSV with a header row that defines at least these three columns:

 * `id`: the identifier by which the workflow should refer to the isolate
 * `species`: name of the species of the isolate, may be empty or `Unknown`
 * `assembly`: path to the FASTA file with the assembled contigs

There may be other columns, and they can be in any order.
See [test/mini/isolates.tsv](test/mini/isolates.tsv) for reference.

Once you have the sample sheet, invoke the workflow as above:

    snakemake --cores all --sdm conda -C samples=path/to/isolates.tsv

By default the results for each `$id` are written into `./results/$id/`.

If you want to run the workflow with different config settings
(see [config/config.yaml](config/config.yaml)), you can override these with

    snakemake --configfile ...

The `--cores` and `--sdm conda` or `--use-conda` are always needed.

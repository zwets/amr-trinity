# AMR Trinity - Snakemake workflow

This workflow is a scaled down and simplified version of the Snakemake workflow
in [hAMRonization Workflow](https://github.com/pha4ge/hAMRonization_workflow.git).

> ResFinder and RGI can process reads, but AMRFinderPlus only works with assemblies,
> which is why the workflow is defined only for FASTA inputs.


## Installation

Create Conda environment *snakemake* (if you don't have any yet)

    conda env create -n snakemake -f workflow/envs/snakemake.yaml

Activate the environment

    conda activate snakemake

Run a smoke test on the NDM mini sample (this may take a while, as tools
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

Once you have the sample sheet, invoke the workflow like above:

    snakemake -C samples=path/to/isolates.tsv

By default the results for each `$id` are written into `./results/$id/`,
and the hamronized summaries are in `./results/results.{json,tsv,html}`.

We omit the mandatory `--cores` and `--sdm conda` arguments here, as these
are being set in the [default profile](profiles/default/config.yaml).  You
can add your own default parameters there, or run an alternative profile:

    snakemake --workflow-profile ...

The workflow itself is configured in the [default config](config/config.yaml),
which again you can edit, or override on the command-line:

    snakemake --configfile ...

Refer to the [Snakemake docs](https://snakemake.readthedocs.io/en/stable/)
for all the excruciating detail.

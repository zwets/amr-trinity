# AMR Trinity

_Run the "Big Three" AMR detection tools with unified output_

**WORK IN PROGRESS**

### Background

This repository provides two ways to run the "Big Three" AMR detection tools
over a collection of assemblies and obtain collated unified output.

The project builds on [hAMRonization](https://github.com/pha4ge/hAMRonization),
which maintains a collection of converters to harmonise AMR tool output formats.

[hAMRonization workflow](https://github.com/pha4ge/hAMRonization_workflow) was
a proof of concept that ran all (18) hAMRonization-supported tools in one go,
but it was very hard to maintain.

In **AMR Trinity** we scale down the hAMRonization workflow to the "Big Three",
the three tools that have their own actively curated databases and algorithms.

 * [AMRFinderPlus](https://github.com/ncbi/amr)
 * [ResFinder](https://bitbucket.org/genomicepidemiology/resfinder)
 * [RGI/CARD](https://github.com/arpcard/rgi)

### Snakemake Workflow

The Snakemake workflow was directly taken from the hAMRonization workflow.
See the [snakemake](snakemake) directory.

### Nextflow Workflow

**WIP**


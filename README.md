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

The Snakemake workflow was directly taken from the hAMRonization workflow.  It
pulls in the three tools and the hamronization tool through Conda.

See the [snakemake](snakemake) directory.

### Nextflow Workflow

The [Nextflow implementation](nextflow) is a "simplest thing that could possibly
work".  In contrast to the Snakemake workflow it uses containers.

A particularly convenient aspect of using containers is that we can include the
database inside the container.

### Containers

The [containers](containers) directory has Dockerfiles to produce the three
containers.

**TODO**
 - Containerise hAMRonization as well?
 - Push containers to Docker Hub, Quay, GHRC


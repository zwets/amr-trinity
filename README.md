# AMR Trinity

_Run the "Big Three" AMR detection tools with unified output_

### Background

This repository provides two ways to run the "Big Three" AMR detection tools
over a collection of assemblies and obtain collated unified output.

The project builds on [hAMRonization](https://github.com/pha4ge/hAMRonization),
which maintains a collection of converters to harmonise AMR tool output formats.

[hAMRonization workflow](https://github.com/pha4ge/hAMRonization_workflow) was
a proof of concept test-case workflow that ran all (18) hAMRonization-supported
tools in one go.

**AMR Trinity** scales down the hAMRonization workflow to the "Big Three", the
three tools that have their own actively curated databases and algorithms.

 * [AMRFinderPlus](https://github.com/ncbi/amr)
 * [ResFinder](https://bitbucket.org/genomicepidemiology/resfinder)
 * [RGI/CARD](https://github.com/arpcard/rgi)

We have two workflow implementations: in Snakemake (a scaled down version of
[hAMRonization workflow](https://github.com/pha4ge/hAMRonization_workflow)) and
in Nextflow.

### Snakemake Workflow

The Snakemake workflow is a stripped-down version of the original hAMRonization
workflow.  It uses the Conda releases of the tools, and automatically installs
their databases on the first run.

See the [snakemake](snakemake) directory.

### Nextflow Workflow

The [Nextflow implementation](nextflow) is more stable and uses the container
releases of the tools (Podman/Docker/Singularity).  The containers come with
databases built-in.

See the [nextflow](nextflow) directory.

### Containers

The [containers](containers) directory has Dockerfiles to produce the containers.
This is no longer needed now that all tools release up-to-date container images,
but we keep them around for reference.


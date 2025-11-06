# AMR Trinity - Containers

This directory has containerfiles to create Podman/Docker containers
for the three AMR detection tools.

> **No longer needed!**
>
> All tools now publish up-to-date container releases, and we use those
> in the Nextflow workflow.  The official releases are published here:
>
>  * AMRFinderPlus: <https://docker.io/ncbi/amr>
>  * ResFinder: <https://docker.io/genomicepidemiology/resfinder>
>  * RGI: <https://quay.io/biocontainers/rgi>
>  * hARMonization: <https://docker.io/finlaymaguire/hamronization> or <https://ghcr.io/zwets/hamronization> 

We keep this directory around in case a custom build is needed.


## Build

To build the container images

    podman build -t rgi:6.0.5 -f Dockerfile.rgi .
    podman build -t resfinder:4.7.2 -f Dockerfile.resfinder .
    podman build -t amrfinderplus:4.0.23 -f Dockerfile.amrfinderplus .


## Run

    podman run --rm -v $PWD:/workdir localhost/amrfinderplus:4.0.23 \
       amrfinder -n CONTIGS -o RESULTFILE [-O SPECIES] [--threads THREADS]

    podman run --rm -v $PWD:/workdir localhost/resfinder:4.7.2 
       resfinder -ifa CONTIGS -o RESULT_DIR [-j RESULT_JSON] [-s SPECIES] [--kma_threads THREAD]

    podman run --rm -v $PWD:/workdir localhost/rgi:6.0.5
       run-rgi -i CONTIGS -o OUTBASE [-n THREADS]


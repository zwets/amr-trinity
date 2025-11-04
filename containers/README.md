# AMR Trinity - Containers

This directory has containerfiles to create Podman/Docker containers
for the three AMR detection tools.

The containers include the latest database for each tool.  They
have been set up such that you don't need to specify the 'in-container'
database location when running the tool


## Build

To build the container images

    podman build -t rgi:6.0.5 -f Dockerfile.rgi .
    podman build -t resfinder:4.7.2 -f Dockerfile.resfinder .
    podman build -t amrfinderplus:4.0.23 -f Dockerfile.amrfinderplus .

> `Dockerfile.all` produces an 'all-in-one' image with all three tools.
> This saves on size (3.3G vs 6.2G) but isn't very modular.


## Run

    podman run --rm -v $PWD:/workdir localhost/amrfinderplus:4.0.23 \
       amrfinder -n CONTIGS -o RESULTFILE [-O SPECIES] [--threads THREADS]

    podman run --rm -v $PWD:/workdir localhost/resfinder:4.7.2 
       resfinder -ifa CONTIGS -o RESULT_DIR [-j RESULT_JSON] [-s SPECIES] [--kma_threads THREAD]

    podman run --rm -v $PWD:/workdir localhost/rgi:6.0.5
       run-rgi -i CONTIGS -o OUTBASE [-n THREADS]


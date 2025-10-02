# AMR Trinity - Containers

This is a quick shot at containerising the three tools _with_ their
databases included, for ease of integration with Nextflow.

The wrapper scripts are set up such that the user needn't pass the
location of the database - which are inside the container.

**TODO** The wrapper scripts are a quick kludge and need cleanup.


## Build

To build the containers

    podman build -t rgi:6.0.5 -f Dockerfile.rgi .
    podman build -t resfinder:4.7.2 -f Dockerfile.resfinder .
    podman build -t amrfinderplus:4.0.23 -f Dockerfile.amrfinderplus .


## Run

To run the wrapper-script in the containers 

    podman run --rm -v $PWD:/workdir localhost/amrfinderplus:4.0.23 \
       amrfinderplus -n CONTIGS -o RESULTFILE [-O SPECIES] [--threads THREADS]

    podman run --rm -v $PWD:/workdir localhost/resfinder:4.7.2 
       resfinder -ifa CONTIGS -o RESULT_DIR [-j RESULT_JSON] [-s SPECIES] [--kma_threads THREAD]

    podman run --rm -v $PWD:/workdir localhost/rgi:6.0.5
       run-rgi --input_sequence CONTIGS --output_file RESULTFILE [--num_threads THREAD]


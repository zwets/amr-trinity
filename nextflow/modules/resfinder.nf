process resfinder {
    container 'docker.io/genomicepidemiology/resfinder:4.7.2'
    containerOptions '--entrypoint ""'
    cpus 2

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('resfinder'), path('metadata.txt'), path('resfinder.json')

    script:
    """
    touch metadata.txt # Leave empty as ResFinder writes all required metadata in its JSON output
    python -m resfinder --acquired --point --disinfectant --species '$species' --ignore_missing_species -ifa $contigs -j resfinder.json -o . --kma_threads ${task.cpus}
    """
}

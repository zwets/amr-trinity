process rgi {
    container 'quay.io/biocontainers/rgi:6.0.5--pyh05cac1d_0'
    cpus 8

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('rgi'), path('metadata.txt'), path('rgi.txt')

    script:
    """
    rgi main -i $contigs -o rgi -n ${task.cpus} --clean
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `rgi main --version` `rgi database --version` >metadata.txt
    """
}

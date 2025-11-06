process amrfinderplus {
    container 'docker.io/ncbi/amr:4.0.23-2025-07-16.1'
    cpus 4

    input:
    tuple val(id), val(species), path(contigs)

    output:
    tuple val(id), val('amrfinderplus'), path('metadata.txt'), path('amrfinderplus.tsv')

    script:
    """
    # Set species to have AFP's required underscore instead of space then set SPECIES_OPT iff SPECIES is supported by AFP
    SPECIES=`echo '$species' | sed -e 's/ /_/g'`
    [ -n "\$SPECIES" ] && amrfinder --list_organisms 2>/dev/null | fgrep -q "\$SPECIES" && SPECIES_OPT="-O \$SPECIES" || SPECIES_OPT=''

    # Run AFP
    amrfinder -n $contigs \$SPECIES_OPT -o amrfinderplus.tsv --threads ${task.cpus}

    # Produce metadata.txt
    DB_VER=`amrfinder -V | fgrep 'Database version:' | cut -d':' -f2`
    printf -- '--input_file_name ${contigs.name} --analysis_software_version %s --reference_database_version %s' `amrfinder -v` \$DB_VER >metadata.txt
    """
}

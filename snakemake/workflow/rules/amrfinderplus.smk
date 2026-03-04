rule get_amrfinder_db:
    localrule: True
    output:
        directory(os.path.join(config['db_dir'], "amrfinderplus", "latest"))
    params:
        db_dir = os.path.join(config['db_dir'], "amrfinderplus")
    log:
        "logs/amrfinderplus_db.log"
    conda:
        "../envs/amrfinderplus.yaml"
    shell:
        """
        amrfinder_update -d '{params.db_dir}' 2>{log}
        # Fix the 'latest' symlink to be relative, so it works from containers too
        ln -srfT "$(realpath '{params.db_dir}/latest')" '{params.db_dir}/latest'
        """

rule run_amrfinderplus:
    message: "Running AMRFinderPlus on {wildcards.sample}"
    output:
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    input:
        contigs = get_assembly,
        db_dir = os.path.join(config['db_dir'], "amrfinderplus", "latest")
    params:
        species = lambda w: get_species(w).replace(' ','_')
    log:
        "logs/amrfinderplus_{sample}.log"
    benchmark:
        "benchmarks/amrfinderplus_{sample}.tsv"
    conda:
        "../envs/amrfinderplus.yaml"
    threads: 4
    resources: runtime = "2m", mem = "500MB" 
    shell:
        """
        # Set SPECIES_OPT if and only if param.species is supported by AFP
        [ -n '{params.species}' ] && amrfinder --list_organisms -d {input.db_dir} 2>/dev/null | fgrep -q '{params.species}' && SPECIES_OPT='-O {params.species}' || SPECIES_OPT=''
        amrfinder --threads {threads} -n '{input.contigs}' $SPECIES_OPT -o '{output.report}' -d '{input.db_dir}' >{log} 2>&1
        sed -En 's/^Software version: (.*)$/--analysis_software_version \\1/p;s/^Database version: (.*)$/--reference_database_version \\1/p' {log} | sort -u >{output.metadata}
        """

rule hamronize_amrfinderplus:
    localrule: True
    output:
        "results/{sample}/amrfinderplus/hamronized_report.tsv"
    input:
        contigs = get_assembly,
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    log:
        "logs/amrfinderplus_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize amrfinderplus --input_file_name {input.contigs} $(cat {input.metadata}) {input.report} >{output} 2>{log}
        """

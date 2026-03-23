rule run_amrfinderplus:
    message: "Running AMRFinderPlus on {wildcards.sample}"
    output:
        report = "results/{sample}/amrfinderplus/report.tsv",
        metadata = "results/{sample}/amrfinderplus/metadata.txt"
    input:
        contigs = get_assembly
    params:
        species = lambda w: get_species(w).replace(' ','_')
    log:
        "logs/amrfinderplus_{sample}.log"
    benchmark:
        "benchmarks/amrfinderplus_{sample}.tsv"
    container:
        "docker://docker.io/ncbi/amr:4.2.7-2026-01-21.1"
    threads: 4
    resources: runtime = "2m", mem = "500MB"
    shell:
        """
        # Set SPECIES_OPT if and only if param.species is supported by AFP
        [ -n '{params.species}' ] && amrfinder --list_organisms 2>/dev/null | fgrep -q '{params.species}' && SPECIES_OPT='-O {params.species}' || SPECIES_OPT=''
        amrfinder --threads {threads} -n '{input.contigs}' $SPECIES_OPT -o '{output.report}' >{log} 2>&1
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
    container:
        "docker://ghcr.io/zwets/hamronization:1.2.0"
    shell:
        """
        hamronize amrfinderplus --input_file_name {input.contigs} $(cat {input.metadata}) {input.report} >{output} 2>{log}
        """

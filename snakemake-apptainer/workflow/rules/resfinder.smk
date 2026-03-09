rule run_resfinder:
    message: "Running ResFinder on {wildcards.sample}"
    output:
        dir = directory("results/{sample}/resfinder"),
        report = "results/{sample}/resfinder/data_resfinder.json"
    input:
        assembly = get_assembly
    params:
        species = branch(get_species, then=get_species, otherwise="Unknown")
    log:
        "logs/resfinder_{sample}.log"
    benchmark:
        "benchmarks/resfinder_{sample}.tsv"
    container:
        "docker://docker.io/genomicepidemiology/resfinder:4.7.2"
    threads: 1  # we process assemblies so ResFinder uses single-threaded blast, not KMA (--kma_threads is not used)
    resources: runtime = "2m", mem = "500MB"
    shell:
        """
        python -m resfinder --acquired --point --disinfectant --species '{params.species}' --ignore_missing_species \
            --kma_threads {threads} -ifa '{input.assembly}' -j {output.report} -o {output.dir} >{log} 2>&1
        """

rule hamronize_resfinder:
    localrule: True
    output:
        "results/{sample}/resfinder/hamronized_report.tsv"
    input:
        "results/{sample}/resfinder/data_resfinder.json",
    log:
        "logs/resfinder_{sample}_hamronize.log"
    container:
        "docker://ghcr.io/zwets/hamronization:1.2.0"
    shell:
        "hamronize resfinder {input} >{output} 2>{log}"


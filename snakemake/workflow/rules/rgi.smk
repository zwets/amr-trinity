rule get_rgi_db:
    localrule: True
    output:
        os.path.join(config['db_dir'], "card", "card.json")
    params:
        db_dir = os.path.join(config['db_dir'], "card")
    log:
        "logs/rgi_db.log"
    shell:
        """{{
        wget -cqO {params.db_dir}/card.tar.bz2 'https://card.mcmaster.ca/latest/data'
        tar -C {params.db_dir} -xf {params.db_dir}/card.tar.bz2
        rm -f {params.db_dir}/card.tar.bz2
        }} >{log} 2>&1
        """

rule run_rgi:
    message: "Running RGI on {wildcards.sample}"
    output:
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    input:
        contigs = get_assembly,
        card_db = os.path.join(config['db_dir'], "card", "card.json")
    params:
        out_dir = "results/{sample}/rgi"
    log:
        "logs/rgi_{sample}.log"
    benchmark:
        "benchmarks/rgi_{sample}.tsv"
    conda:
        "../envs/rgi.yaml"
    threads: 8
    resources: runtime = "5m", mem = "1GB"
    shell:
        """{{
        # We are forced to change directory because 'rgi load' clumsily writes its
        # database in the PWD, where it will bork and be borked by any parallel job.
        # The output directory is safe because it is unique to the job.  But we can
        # only go there if we first make the paths we need absolute.
        FNA="$(realpath '{input.contigs}')"
        CARD="$(realpath '{input.card_db}')"
        META="$(realpath '{output.metadata}')"
        cd {params.out_dir}
        rgi load -i "$CARD" --local
        rgi main --local --clean --input_sequence "$FNA" --output_file rgi --num_threads {threads}
        # Now remove the localDB (why doesn't it put this in /tmp?)
        rm -rf localDB || true
        echo "--analysis_software_version $(rgi main --version) --reference_database_version $(rgi database --version)" >"$META"
        }} >{log} 2>&1
        """

rule hamronize_rgi:
    localrule: True
    output:
        "results/{sample}/rgi/hamronized_report.tsv"
    input:
        contigs = get_assembly,
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    log:
        "logs/resfinder_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(cat {input.metadata}) --input_file_name {input.contigs} {input.report} > {output}
        """

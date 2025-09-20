rule get_rgi_db:
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
    input:
        contigs = get_assembly,
        card_db = os.path.join(config['db_dir'], "card", "card.json")
    output:
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    message: "Running RGI on {wildcards.sample}"
    log:
        "logs/rgi_{sample}.log"
    conda:
        "../envs/rgi.yaml"
    threads:
        config['threads']['rgi']
    params:
        out_dir = "results/{sample}/rgi"
    shell:
        """{{
        # Inconveniently we need to cd to the output directory because 'rgi load' writes
        # its database where it runs, and we don't want two jobs writing in one location.
        # Before we change directory we need to make all file paths absolute.
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
    input:
        contigs = get_assembly,
        report = "results/{sample}/rgi/rgi.txt",
        metadata = "results/{sample}/rgi/metadata.txt"
    output:
        "results/{sample}/rgi/hamronized_report.tsv"
    conda:
        "../envs/hamronization.yaml"
    shell:
        """
        hamronize rgi $(cat {input.metadata}) --input_file_name {input.contigs} {input.report} > {output}
        """

rule get_resfinder_db:
    localrule: True
    output:
        res_db = directory(os.path.join(config['db_dir'], "resfinder_db")),
        point_db = directory(os.path.join(config['db_dir'], "pointfinder_db")),
        disinf_db = directory(os.path.join(config['db_dir'], "disinfinder_db"))
    params:
        # This picks the latest version of the three databases (tools will report version)
        res_ver = 'master',
        point_ver = 'master',
        disinf_ver = 'master'
    log:
        "logs/resfinder_db.log"
    conda:
        "../envs/resfinder.yaml"
    shell:
        """
        {{
        # Check out the databases at the commit specified by param.*_ver above
        git clone --depth=1 -b {params.res_ver} https://bitbucket.org/genomicepidemiology/resfinder_db.git {output.res_db}
        git clone --depth=1 -b {params.point_ver} https://bitbucket.org/genomicepidemiology/pointfinder_db.git {output.point_db}
        git clone --depth=1 -b {params.disinf_ver} https://bitbucket.org/genomicepidemiology/disinfinder_db.git {output.disinf_db}
        # Index the databases
        grep -Ev '^[[:space:]]*(#|$)' {output.res_db}/config    | cut -f1 | xargs -I@ kma_index -i {output.res_db}/@.fsa -o {output.res_db}/@
        grep -Ev '^[[:space:]]*(#|$)' {output.point_db}/config  | cut -f1 | xargs -I@ sh -c 'kma_index -i {output.point_db}/@/*.fsa -o {output.point_db}/@/@'
        grep -Ev '^[[:space:]]*(#|$)' {output.disinf_db}/config | cut -f1 | xargs -I@ kma_index -i {output.disinf_db}/@.fsa -o {output.disinf_db}/@
        }} >{log} 2>&1
        """

rule run_resfinder:
    message: "Running ResFinder on {wildcards.sample}"
    output:
        dir = directory("results/{sample}/resfinder"),
        report = "results/{sample}/resfinder/data_resfinder.json"
    input:
        assembly = get_assembly,
        res_db = os.path.join(config['db_dir'], 'resfinder_db'),
        point_db = os.path.join(config['db_dir'], 'pointfinder_db'),
        disinf_db = os.path.join(config['db_dir'], 'disinfinder_db')
    params:
        species = branch(get_species, then=get_species, otherwise="Unknown"),
    log:
        "logs/resfinder_{sample}.log"
    benchmark:
        "benchmarks/resfinder_{sample}.tsv"
    conda:
        "../envs/resfinder.yaml"
    threads: 1  # we process assemblies so ResFinder uses single-threaded blast, not KMA (--kma_threads is not used)
    resources: runtime = "2m", mem = "500MB"
    shell:
        """
        run_resfinder.py --acquired --point --disinfectant --species '{params.species}' --ignore_missing_species \
            --kma_threads {threads} -db_res '{input.res_db}' -db_point '{input.point_db}' -db_disinf '{input.disinf_db}' \
            -ifa '{input.assembly}' -j {output.report} -o {output.dir} >{log} 2>&1
        """

rule hamronize_resfinder:
    localrule: True
    output:
        "results/{sample}/resfinder/hamronized_report.tsv"
    input:
        "results/{sample}/resfinder/data_resfinder.json",
    log:
        "logs/resfinder_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        "hamronize resfinder {input} >{output} 2>{log}"


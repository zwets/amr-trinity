rule get_resfinder_db:
    output:
        res_db = directory(os.path.join(config['db_dir'], "resfinder_db")),
        point_db = directory(os.path.join(config['db_dir'], "pointfinder_db")),
        disinf_db = directory(os.path.join(config['db_dir'], "disinfinder_db"))
    log:
        "logs/resfinder_db.log"
    conda:
        "../envs/resfinder.yaml"
    params:
        # This picks the latest version of the three databases (tools will report version)
        res_ver = 'master',
        point_ver = 'master',
        disinf_ver = 'master'
    shell:
        """
        {{ set -euo pipefail
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

rule run_resfinder_fna:
    input:
        assembly = get_assembly,
        res_db = os.path.join(config['db_dir'], 'resfinder_db'),
        point_db = os.path.join(config['db_dir'], 'pointfinder_db'),
        disinf_db = os.path.join(config['db_dir'], 'disinfinder_db')
    output:
        dir = directory("results/{sample}/resfinder-fna"),
        report = "results/{sample}/resfinder-fna/data_resfinder.json"
    message: "Running rule run_resfinder_fna on {wildcards.sample} assembly"
    log:
        "logs/resfinder-fna_{sample}.log"
    conda:
        "../envs/resfinder.yaml"
    threads:
        config['threads']
    params:
        species = branch(get_species, then=get_species, otherwise="Unknown"),
    shell:
        """
        mkdir -p {output.dir}
        run_resfinder.py --acquired --point --disinfectant --species '{params.species}' --ignore_missing_species \
            -db_res '{input.res_db}' -db_point '{input.point_db}' -db_disinf '{input.disinf_db}' \
            -ifa '{input.assembly}' -j {output.report} -o {output.dir} >{log} 2>&1
        """

rule run_resfinder_fqs:
    input:
        read1 = get_read1, read2 = get_read2,
        res_db = os.path.join(config['db_dir'], 'resfinder_db'),
        point_db = os.path.join(config['db_dir'], 'pointfinder_db'),
        disinf_db = os.path.join(config['db_dir'], 'disinfinder_db')
    output:
        dir = directory("results/{sample}/resfinder-fqs"),
        report = "results/{sample}/resfinder-fqs/data_resfinder.json"
    message: "Running rule run_resfinder_fqs on {wildcards.sample} reads"
    log:
        "logs/resfinder-fqs_{sample}.log"
    conda:
        "../envs/resfinder.yaml"
    threads:
        config['threads']
    params:
        species = branch(get_species, then=get_species, otherwise="Unknown"),
    shell:
        """
        mkdir -p {output.dir}
        run_resfinder.py --acquired --point --disinfectant --species '{params.species}' --ignore_missing_species \
            -db_res '{input.res_db}' -db_point '{input.point_db}' -db_disinf '{input.disinf_db}' \
            -ifq '{input.read1}' '{input.read2}' -j {output.report} -o {output.dir} >{log} 2>&1
        """

rule hamronize_resfinder:
    input:
        report = "results/{sample}/resfinder-{sfx}/data_resfinder.json",
    output:
        "results/{sample}/resfinder-{sfx}/hamronized_report.tsv"
    log:
        "logs/resfinder-{sfx}_{sample}_hamronize.log"
    conda:
        "../envs/hamronization.yaml"
    shell:
        "hamronize resfinder {input.report} >{output} 2>{log}"


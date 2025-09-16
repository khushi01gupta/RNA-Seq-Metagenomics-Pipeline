import os

configfile: "config.yaml"

SAMPLES = config["samples"]
KRAKEN2_DB = config["kraken2_db"]
THREADS = config["threads"]

rule all:
    input:
        expand("results/{sample}_bracken.txt", sample=SAMPLES),
        expand("results/{sample}_krona.html", sample=SAMPLES)

rule kraken2:
    input:
        "data/{sample}.fastq.gz"
    output:
        report="results/{sample}_kraken2_report.txt",
        out="results/{sample}_kraken2_out.txt"
    threads: THREADS
    shell:
        """
        kraken2 --db {KRAKEN2_DB} \
            --threads {threads} \
            --report {output.report} \
            --output {output.out} {input}
        """

rule bracken:
    input:
        "results/{sample}_kraken2_report.txt"
    output:
        "results/{sample}_bracken.txt"
    shell:
        """
        bracken -d {KRAKEN2_DB} \
            -i {input} \
            -o {output} \
            -r 100 -l S
        """

rule krona:
    input:
        "results/{sample}_kraken2_out.txt"
    output:
        "results/{sample}_krona.html"
    shell:
        """
        ktImportTaxonomy {input} -o {output}
        """

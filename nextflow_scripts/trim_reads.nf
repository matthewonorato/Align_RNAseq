process trim_reads {

    tag { sample_id }
    publishDir "${params.outdir}/qc", mode: 'copy', pattern: '*_fastp.{json,html}'  // Reports only, not trimmed reads
    cpus 4
    memory '6 GB'

    input:
    tuple val(sample_id),
          val(read_ends),
          path(r1),
          path(r2)

    output:
    tuple val(sample_id), path("trimmed_*"), emit: trimmed_reads
    path "*_fastp.json", emit: trimmed_json_report
    path "*_fastp.html", emit: trimmed_html_report

    script:
    def r1_trim = "trimmed_${r1.name}"
    def r2_trim = "trimmed_${r2.name}"
    def json_report = "${sample_id}_fastp.json"
    def html_report = "${sample_id}_fastp.html"

    def trim_cmd = (read_ends == "paired") ?
        "/mnt/disks/resources/software/miniconda3/envs/Py-3.12/bin/fastp --in1 ${r1} --in2 ${r2} --out1 ${r1_trim} --out2 ${r2_trim} --detect_adapter_for_pe --thread ${task.cpus} --length_required ${params.min_read_len} --json ${json_report} --html ${html_report}" :
        "/mnt/disks/resources/software/miniconda3/envs/Py-3.12/bin/fastp --in1 ${r1} --out1 ${r1_trim} --thread ${task.cpus} --length_required ${params.min_read_len} --json ${json_report} --html ${html_report}"

    """
    ${trim_cmd}

    """
}

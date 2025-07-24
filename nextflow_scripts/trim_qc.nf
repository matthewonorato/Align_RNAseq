process trim_qc {

    tag { sample_id }
    publishDir "${params.outdir}/qc", mode: 'copy'
    cpus 1
    memory '2 GB'

    input:
    tuple val(sample_id),
          val(read_ends),
          path(r1_trim),
          path(r2_trim)

    output:
    path "*_fastqc.zip", emit: trimmed_qc_zip
    path "*_fastqc.html", emit: trimmed_qc_report

    script:
    def trimmed_reads = (read_ends == "paired") ? "${r1_trim} ${r2_trim}" : "${r1_trim}"

    """
    /mnt/disks/resources/software/FastQC/fastqc --threads ${task.cpus} ${trimmed_reads}

    """
}

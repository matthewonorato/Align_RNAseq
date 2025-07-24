process initial_qc {

    tag { sample_id }
    publishDir "${params.outdir}/qc", mode: 'copy'
    cpus 1
    memory '2 GB'
    
    input:
    tuple val(sample_id),
          val(read_ends),
          path(r1),
          path(r2)

    output:
    path "*_fastqc.zip", emit: raw_qc_zip
    path "*_fastqc.html", emit: raw_qc_report

    script:
    def reads = (read_ends == "paired") ? "${r1} ${r2}" : "${r1}"

    """
    /mnt/disks/resources/software/FastQC/fastqc --threads ${task.cpus} ${reads}
    
    """
}

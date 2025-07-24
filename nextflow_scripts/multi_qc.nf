process multi_qc {

    publishDir "${params.outdir}", mode: 'copy', pattern: '*.html'
    cpus 1
    memory '2 GB'

    input:
    path qc_files

    output:
    path "*.html", emit: multiqc_report
    path "*_data", emit: multiqc_data

    script:
    """
    /mnt/disks/resources/software/miniconda3/envs/Py-3.12/bin/multiqc ${qc_files.join(' ')} --filename ${params.project_name}_multiqc_report
    """
}

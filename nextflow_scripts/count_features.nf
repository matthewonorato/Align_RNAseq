process count_features {

    tag { sample_id }
    publishDir "${params.outdir}/rsem_output", mode: 'copy', pattern: '*.{genes,isoforms}.results'
    cpus 8
    memory '40 GB'

    input:
    tuple val(sample_id),
          val(read_ends),
          path(bam_genes),
          path(bam_transcripts)

    output:
    path "*.stat", emit: rsem_dir
    path "*.genes.results", emit: gene_counts
    path "*.isoforms.results", emit: transcript_counts

    script:
    def count_cmd = (read_ends == "paired") ?
        "/mnt/disks/resources/software/RSEM-1.3.3/rsem-calculate-expression --alignments --paired-end --strandedness ${params.strandedness} --num-threads ${task.cpus} --no-bam-output ${bam_transcripts} ${params.rsem_index} ${sample_id}" :
        "/mnt/disks/resources/software/RSEM-1.3.3/rsem-calculate-expression --alignments --strandedness ${params.strandedness} --num-threads ${task.cpus} --no-bam-output --fragment-length-mean ${params.avg_read_len} --fragment-length-sd ${params.sd_read_len} ${bam_transcripts} ${params.rsem_index} ${sample_id}"

    """
    ${count_cmd}

    """
}

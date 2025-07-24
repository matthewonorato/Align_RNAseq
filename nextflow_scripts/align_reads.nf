process align_reads {

    tag { sample_id }
    publishDir "${params.outdir}/star_output", mode: 'copy'
    cpus 4
    memory '32 GB'  // Since STAR consumes ~30 GB/sample, you can only safely run up to 3 alignments in parallel

    input:
    tuple val(sample_id),
          val(read_ends),
          path(r1_trim),
          path(r2_trim)

    output:
    tuple val(sample_id), path("*_Aligned.sortedByCoord.out.bam"), emit: bam_genes
    tuple val(sample_id), path("*_Aligned.sortedByCoord.out.bam.bai"), emit: bam_index
    tuple val(sample_id), path("*_Aligned.toTranscriptome.out.bam"), emit: bam_transcripts
    path "*_SJ.out.tab", emit: splice_junctions
    path "*_Log.final.out", emit: log_final
    path "*_Log.out", emit: log_run_parameters
    path "*_Log.progress.out", emit: log_run_progress

    script:
    def trimmed_reads = (read_ends == "paired") ? "${r1_trim} ${r2_trim}" : "${r1_trim}"

    """
    /mnt/disks/resources/software/STAR-2.7.11b/source/STAR --runMode alignReads --runThreadN ${task.cpus} --readFilesIn ${trimmed_reads} --readFilesCommand zcat --genomeDir ${params.star_index} --limitBAMsortRAM 20000000000 --outFileNamePrefix ${sample_id}_ --outSAMtype BAM SortedByCoordinate --outSJtype Standard --quantMode TranscriptomeSAM    

    /mnt/disks/resources/software/samtools-1.20/samtools index --bai --threads ${task.cpus} ${sample_id}_Aligned.sortedByCoord.out.bam

    """
}

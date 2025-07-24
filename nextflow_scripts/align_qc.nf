process align_qc {

    tag { sample_id }
    publishDir "${params.outdir}/qc", mode: 'copy'
    cpus 1
    memory '2 GB'

    input:
    tuple val(sample_id),
          val(read_ends),
          path(bam_genes),
          path(bam_transcripts)

    output:
    path "*_inferExperiment.txt", emit: strandedness_file
    path "*_readDistribution.txt", emit: gene_feature_file

    script:
    """
    /mnt/disks/resources/software/miniconda3/envs/Py-3.12/bin/infer_experiment.py --refgene=${params.bed12} --input=${bam_genes} --sample-size=2000000 > ${sample_id}_inferExperiment.txt

    /mnt/disks/resources/software/miniconda3/envs/Py-3.12/bin/read_distribution.py --refgene=${params.bed12} --input=${bam_genes} > ${sample_id}_readDistribution.txt

    """
}

include { initial_qc }       from './nextflow_scripts/initial_qc.nf'
include { trim_reads }       from './nextflow_scripts/trim_reads.nf'
include { trim_qc }          from './nextflow_scripts/trim_qc.nf'
include { align_reads }      from './nextflow_scripts/align_reads.nf'
include { align_qc }         from './nextflow_scripts/align_qc.nf'
include { count_features }   from './nextflow_scripts/count_features.nf'
include { multi_qc }         from './nextflow_scripts/multi_qc.nf'

workflow {

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            def sample_id     = row.sample_id
            def read_ends     = row.library_layout?.toLowerCase()
            def r1            = file(row.r1_path)
            def r2            = file(row.r2_path)
            tuple(sample_id, read_ends, r1, r2)
        }
        .set { metadata_ch }

    initial_qc(metadata_ch)
    trim_reads(metadata_ch)

    metadata_ch
        .join(trim_reads.out.trimmed_reads)  // Outputs flat tuple(sample_id, meta_fields, trimmed_read_files)
        .map { sample_id, read_ends, r1, r2, trimmed ->
            def trimmed_files = trimmed instanceof List ? trimmed : [trimmed]
            def (r1_trim, r2_trim) = trimmed_files.size() > 1 ? trimmed_files : [trimmed_files[0], r2]  // r2: Keep dummy file
            tuple(sample_id, read_ends, r1_trim, r2_trim)
        }
        .set { metadata_with_trimmed_reads_ch }

    trim_qc(metadata_with_trimmed_reads_ch)
    align_reads(metadata_with_trimmed_reads_ch)

    metadata_ch
        .join(align_reads.out.bam_genes)
        .join(align_reads.out.bam_transcripts)
        .map { sample_id, read_ends, r1, r2, bam_genes, bam_transcripts ->
            tuple(sample_id, read_ends, bam_genes, bam_transcripts)
        }
        .set { metadata_with_aligned_reads_ch }

    align_qc(metadata_with_aligned_reads_ch)
    count_features(metadata_with_aligned_reads_ch)

    multi_qc(initial_qc.out.raw_qc_zip.mix(
        initial_qc.out.raw_qc_report,
        trim_reads.out.trimmed_json_report,
        trim_reads.out.trimmed_html_report,
        trim_qc.out.trimmed_qc_zip,
        trim_qc.out.trimmed_qc_report,
        align_reads.out.log_final,
        align_qc.out.strandedness_file,
        align_qc.out.gene_feature_file
    ).collect())
}

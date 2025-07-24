# Alignment Pipeline 
**QC → trim → QC → align → sort/index → QC → quantify → report → aggregate → annotate → normalize → :)**

**Goal:** Align reads to a reference genome to quantify genes and transcripts from RNA-Seq data. Starting with fastq files and a sample sheet, this pipeline will do the following:
- **Script 1:** QC raw reads (fastqc), trim them (fastp), QC the trimmed reads (fastqc), align the reads to a reference genome (STAR), QC the aligned bam files (RSeQC), count genes and transcripts (RSEM), and create a final QC report (MultiQC)
- **Script 2:** Perform a final merge of all samples, add gene/transcript annotations from the GTF file, and normalize data in a few different ways, such as log2CPM and z-score (custom R script)

# Multisample workflow for gatk4 preprocessing

## General overview

Takes sample sheet as an input, which specifies each lane of sequencing data per lane. Is based on gatk4 best practice guidelines. 

Workflow:
- Fastq to unmapped bam
- Unmapped bam to aligned and processed bam
- Variant calling using HaploType caller produces g.vcf file for each sample

Optimized for Yale Ruddle HPC. Uses subworkflow structure - main workflow calls subworkflow for each unique sample id. 

## Inputs

Sample sheet in following structure (no header!). See `samples.txt` as an example.

Sample_id|Readgroup|Fastq_file_R1|Fastq_file_R2

Samples may have multiple fastqs (multiple lanes of sequencing).

Also reference genome, calling targets etc need to be specified in wdl inputs.

## Outputs

Per sample files:
- unmapped bam(s), one per lane
- bam and index and md5
- gvcf and index
- bqsr and duplicate reads metrics

List of unique sample ids in sample sheet.

## Launching the pipeline

Make sample sheet, modify inputs, options and launch files as needed.

Use `sbatch launch_cromwell.sh`


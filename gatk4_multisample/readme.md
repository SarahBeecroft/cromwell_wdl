# Multisample workflow for gatk4 preprocessing

## General overview

Takes sample sheet as an input, which specifies each lane of sequencing data per lane. Is based on gatk4 best practice guidelines. 

Workflow consists of two scripts:

1) Multisample_Fastq_to_Gvcf_GATK4.wdl
- Fastq to unmapped bam
- Unmapped bam to aligned and processed bam
- Variant calling using HaploType caller produces g.vcf file for each sample

2) Joint genotyping and vcf processing for g.vcf files produced be previous script.

Optimized for Yale Ruddle HPC. Uses subworkflow structure - main workflow calls subworkflow for each unique sample id. 

## Module requirements (Pipeline has been tested with these versions)

```
BWA/0.7.15-foss-2016a
GATK/4.0.6.0-Java-1.8.0_121
SAMtools/1.5-foss-2016b
picard/2.9.0-Java-1.8.0_121
Python/2.7.13-foss-2016b
```
On Ruddle after you have loaded the variants do not forget to `module save`, by doing this the modules are available for every queued job.

## Multisample_Fastq_to_Gvcf
### Inputs

Sample sheet in following structure (no header!). See `samples.txt` as an example.

Sample_id|Readgroup|Fastq_file_R1|Fastq_file_R2

Samples may have multiple fastqs (multiple lanes of sequencing).

Also reference genome, calling targets etc need to be specified in wdl inputs.

### Outputs

Per sample files:
- unmapped bam(s), one per lane
- bam and index and md5
- gvcf and index
- bqsr and duplicate reads metrics

List of unique sample ids in sample sheet.

### Launching the pipeline

Make sample sheet, modify inputs, options and launch files as needed.

_General recommendation_: First, make a directory for your project in your scratch space. Then copy launch scpript, inputs json and options file into that directory, and modify there. No need to copy the wdls or jar file. 

**As cromwell generates a lot of intermediate files it is advised to run all the jobs in the scratch space.** 

Use `sbatch launch_cromwell.sh`

After the pipeline has completed you can move outputs to a new directory to get a cleaner output. I usually make directory called 'processed', and then move files to that directory using command similar to this (one has to find a search pattern that finds all samples based on sample_ids in the project):
`find Multisample_Fastq_to_Gvcf_GATK4/ -name 'NMD*' -exec mv {} processed/ \;`
or more generalizable command moving all files to processed directory: `find Multisample_Fastq_to_Gvcf_GATK4/ -type f -exec mv {} processed/ \;`

## Multisample_jointgt_GATK4.wdl

***Important***: This workflow need at least 1 wgs or 30 wes samples due to VQSR requirements. Panels are not supported. 

### Inputs

Sample sheet in following structure (no header!). See `gvcfs.txt` as an example.

Sample_id|g.vcf|g.vcf.tbi

Each sample should have one g.vcf file.

Also reference genome, calling targets etc need to be specified in wdl inputs.

For JointGenotyping.unpadded_intervals_file - cannot use targets file with all exome targets, as it iterates over all targets, and thus generates > 200 000 jobs to go through each exome target. I have tested it with the wgs calling intervals, which worked fine, as WES targets are applied to haplotype caller anyways. 

### Outputs

Per sample files:
- callset vcf with index
- variant calling metrics

### Launching the pipeline

Make sample sheet, modify inputs, options and launch files as needed.

Use `sbatch launch_cromwell_jointgt.sh`

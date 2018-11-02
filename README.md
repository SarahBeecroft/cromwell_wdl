# cromwell_wdl
This repo consists of my wdl scripts and cromwell confs optimised for Yale HPC - Ruddle

Currently the repo consists of 3 wdl scripts.

## Inputs

A) Sample sheet
The current input file or 'sample sheet' is expected to contain 3 columns (or more, but 3 first one are parsed for input) without header row. Fastq files are without directory, as the directory is a separate input.

| prefix | fastq_R1 | fastq_R2 |

B) References etc should be specified in _inputs.json file as needed.

## Module requirements

You should have loaded the following modules (tested with these versions)

```
BWA/0.7.15-foss-2016a
GATK/3.8-0-Java-1.8.0_121
picard/2.9.0-Java-1.8.0_121
R/3.4.1-foss-2016b
VCFtools/0.1.14-foss-2016a-Perl-5.22.1
GCC/6.3.0-2.27 #for verify_bam_id
```

On Ruddle after you have loaded the variants do not forget to `module save`, by doing this the modules are available for every queued job.

## Wdl workflows
### fastq_to_gvcf_multisample
The script follows GATK3 pipeline. It takes input as a sample sheet specified above. The steps in the pipeline are:
  
    a) read alingment using bwa mem
    b) sorting sam using picard
    c) marking duplicates using picard
    d) reclibrating base scores using GATK (4 steps: pre, post, analyzing covariates and printing reads)
    e) calling variants using GATK HaplotypeCaller in '--emitRefConfidence GVCF' mode
    
The outputs are specified for the workflow and copied to separate directory specify in options file. However they are save following cromwell file system. And should be copied out for storage and subsequent use. You can use

`find ${results_dir} -name '*${file_suffix}' -exec cp {} ${target_dir} \;`

### bam_level_QC
This script incorporates 2 tools: 
    
    a) coverage analysis with Picard CollectHsMetrics
    b) contamination check with verify_bamid
  
The inputs is list of sample prefixes which are stored as a column in sample sheet (the same sample sheet can be used as for fastq_to_gvcf_multisample script), and the directory where they are. After running fastq_to_gvcf_multisample workflow, you need to copy the bam files to one directory. The script currently assumes the suffix to be just .bam.

### gvcfs_to_annotated_vcf

This script incorporates 3 parts: 
    
    a) joint genotyping using GATK GenotypeGVCFs
    b) collecting variant metrics using picard CollectVariantCallingMetrics, and vcftools --relatedness2 and --het for X chromosome tools for estimating relatedness and sex respectively.
    c) annotating the dataset with vep
    

## Executing the wdl scripts using cromwell.

Currently cromwell is not yet available as a module on Ruddle, but one can use downloaded jar file. The cromwell should be executed from separate queued job or using interactive mode (former is encouraged).

Specify the files as needed.

```
#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J cromwell_wrap
#SBATCH --mem=8000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/sp2249/cromwell/slurm.conf -jar /gpfs/ycga/project/ysm/lek/sp2249/cromwell/cromwell-36.jar run /gpfs/ycga/project/ysm/lek/sp2249/cromwell/fastq_to_gvcf_multisample.wdl -i fastq_to_gvcf_multisample_inputs.json  -o fastq_to_gvcf_multisample.options
```


 

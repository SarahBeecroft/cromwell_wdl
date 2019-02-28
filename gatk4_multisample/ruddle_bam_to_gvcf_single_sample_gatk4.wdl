## Copyright Broad Institute, 2018
## 
## This WDL pipeline implements data pre-processing according to the GATK Best Practices 
## (June 2016).  
##
## Requirements/expectations :
## - Pair-end sequencing data in unmapped BAM (uBAM) format
## - One or more read groups, one per uBAM file, all belonging to a single sample (SM)
## - Input uBAM files must additionally comply with the following requirements:
## - - filenames all have the same suffix (we use ".unmapped.bam")
## - - files must pass validation by ValidateSamFile 
## - - reads are provided in query-sorted order
## - - all reads must have an RG tag
##
## Output :
## - A clean BAM file and its index, suitable for variant discovery analyses.
##
## Software version requirements (see recommended dockers in inputs JSON)
## - GATK 4 or later
## - Picard (see gotc docker)
## - Samtools (see gotc docker)
## - Python 2.7
##
## Cromwell version support 
## - Successfully tested on v32
## - Does not work on versions < v23 due to output syntax
##
## Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
##
## LICENSING : 
## This script is released under the WDL source code license (BSD-3) (see LICENSE in 
## https://github.com/broadinstitute/wdl). Note however that the programs it calls may 
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script. Please see the dockers
## for detailed licensing information pertaining to the included programs.


## Adapted to Yale Ruddle HPC by Sander Pajusalu (sander.pajusalu@yale.edu)

# WORKFLOW DEFINITION 
workflow Bam_to_Gvcf_GATK4 {

  String sample_name
  File bam
  File bam_index

  String ref_name
 
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  
  File scattered_calling_intervals_list
  Array[File] scattered_calling_intervals = read_lines(scattered_calling_intervals_list)

  String base_file_name = sample_name + "." + ref_name


  scatter (interval_file in scattered_calling_intervals) {

    # Generate GVCF by interval
    call HaplotypeCaller {
      input:
        input_bam = bam,
        input_bam_index = bam_index,
        interval_list = interval_file,
        output_filename = base_file_name + ".g.vcf.gz",
        ref_dict = ref_dict,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index
    }
  }

  # Merge per-interval GVCFs
  call MergeGVCFs {
    input:
      input_vcfs = HaplotypeCaller.output_vcf,
      input_vcfs_indexes = HaplotypeCaller.output_vcf_index,
      output_filename = base_file_name + ".g.vcf.gz"
  }

  # Outputs that will be retained when execution is complete  
  output {
    File output_vcf = MergeGVCFs.output_vcf
    File output_vcf_index = MergeGVCFs.output_vcf_index
  } 
}

# TASK DEFINITIONS


# HaplotypeCaller per-sample in GVCF mode
task HaplotypeCaller {
  File input_bam
  File input_bam_index
  File interval_list
  String output_filename
  File ref_dict
  File ref_fasta
  File ref_fasta_index
  Float? contamination

  String? java_options
  String java_opt = select_first([java_options, "-XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10"])


  command <<<
  set -e
  
    gatk --java-options "-Xmx15000m ${java_opt}" \
      HaplotypeCaller \
      -R ${ref_fasta} \
      -I ${input_bam} \
      -L ${interval_list} \
      -O ${output_filename} \
      -contamination ${default=0 contamination} \
      -ERC GVCF
  >>>

  runtime {
    cpus: 4
    requested_memory: 16000
  }

  output {
    File output_vcf = "${output_filename}"
    File output_vcf_index = "${output_filename}.tbi"
  }
}

# Merge GVCFs generated per-interval for the same sample
task MergeGVCFs {
  Array[File] input_vcfs
  Array[File] input_vcfs_indexes
  String output_filename


  command <<<
  set -e

    gatk --java-options "-Xmx15000m"  \
      MergeVcfs \
      --INPUT ${sep=' --INPUT ' input_vcfs} \
      --OUTPUT ${output_filename}
  >>>

  runtime {
    cpus: 8
    requested_memory: 16000
  }


  output {
    File output_vcf = "${output_filename}"
    File output_vcf_index = "${output_filename}.tbi"
  }
}


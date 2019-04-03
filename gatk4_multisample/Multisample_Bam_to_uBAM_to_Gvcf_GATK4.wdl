# WORKFLOW DEFINITION 

import "ruddle_bam_to_ubam_to_gvcf_single_sample_gatk4.wdl" as single_wf


workflow Multisample_Bam_to_Ubam_to_Gvcf_GATK4 {

  File inputSamplesFile
  Array[Array[String]] inputSamples = read_tsv(inputSamplesFile)

  String unmapped_bam_suffix
  String ref_name
 
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File ref_amb
  File ref_ann
  File ref_bwt
  File ref_pac
  File ref_sa
  File? ref_alt

  String bwa_commandline
  Int compression_level
  
  File dbSNP_vcf
  File dbSNP_vcf_index
  Array[File] known_indels_sites_VCFs
  Array[File] known_indels_sites_indices

  File scattered_calling_intervals_list


  # Align flowcell-level unmapped input bams in parallel
  

  scatter (sample in inputSamples) {

    String sample_name = sample[0]
    String input_bam = sample[1]
    


   call single_wf.Bam_to_Ubam_to_Gvcf_GATK4 { 
      input: 

        input_bam = input_bam,
        sample_name = sample_name,

        
        unmapped_bam_suffix = unmapped_bam_suffix,

        ref_name = ref_name,
       
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        ref_dict = ref_dict,
        ref_amb = ref_amb,
        ref_ann = ref_ann,
        ref_bwt = ref_bwt,
        ref_pac = ref_pac,
        ref_sa = ref_sa,
        ref_alt = ref_alt,

        bwa_commandline = bwa_commandline,
        compression_level = compression_level,
        
        dbSNP_vcf = dbSNP_vcf,
        dbSNP_vcf_index = dbSNP_vcf_index,
        known_indels_sites_VCFs = known_indels_sites_VCFs,
        known_indels_sites_indices = known_indels_sites_indices,

        scattered_calling_intervals_list = scattered_calling_intervals_list
    }

  }
  # Outputs that will be retained when execution is complete  
  output {
    Array[File] unmapped_bam = Bam_to_Ubam_to_Gvcf_GATK4.unmapped_bam
    Array[File] duplication_metrics = Bam_to_Ubam_to_Gvcf_GATK4.duplication_metrics
    Array[File] bqsr_report = Bam_to_Ubam_to_Gvcf_GATK4.bqsr_report
    Array[File] analysis_ready_bam = Bam_to_Ubam_to_Gvcf_GATK4.analysis_ready_bam
    Array[File] analysis_ready_bam_index = Bam_to_Ubam_to_Gvcf_GATK4.analysis_ready_bam_index
    Array[File] analysis_ready_bam_md5 = Bam_to_Ubam_to_Gvcf_GATK4.analysis_ready_bam_md5
    Array[File] output_vcf = Bam_to_Ubam_to_Gvcf_GATK4.output_vcf
    Array[File] output_vcf_index = Bam_to_Ubam_to_Gvcf_GATK4.output_vcf_index
  } 

}


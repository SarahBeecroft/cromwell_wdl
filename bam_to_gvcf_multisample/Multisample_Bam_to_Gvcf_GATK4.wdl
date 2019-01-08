# WORKFLOW DEFINITION 

import "ruddle_bam_to_gvcf_single_sample_gatk4.wdl" as single_wf


workflow Multisample_Fastq_to_Gvcf_GATK4 {

  File inputSamplesFile
  Array[Array[String]] inputSamples = read_tsv(inputSamplesFile)

  String ref_name
 
  File ref_fasta
  File ref_fasta_index
  File ref_dict


  File scattered_calling_intervals_list


  scatter (sample in inputSamples) {

   call single_wf.Bam_to_Gvcf_GATK4 { 
      input: 

        sample_name = sample[0],
        input_bam = sample[1],


        ref_name = ref_name,
       
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        ref_dict = ref_dict,

        scattered_calling_intervals_list = scattered_calling_intervals_list
    }

  }
  # Outputs that will be retained when execution is complete  
  output {

    Array[File] output_vcf = Bam_to_Gvcf_GATK4.output_vcf
    Array[File] output_vcf_index = Bam_to_Gvcf_GATK4.output_vcf_index
  } 
}

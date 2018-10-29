# This is a sample script for bam level QC workflow wdl script. 
# inputSamplesFile should have prefix defned in 1st column
# reference files and picard are defined as strings to avoid dealing with indices and copying files.
# Make sure that you have picard and GCC ready to be accessed from command line. 
# Tested with the following versions on Ruddle:
# module load picard/2.9.0-Java-1.8.0_121
# module load GCC/6.3.0-2.27


workflow bam_QC {
  
  String ref
  String targets
  String verify_bamid
  String contam_vcf

  File inputSamplesFile
  Array[Array[String]] inputSamples = read_tsv(inputSamplesFile)
  String bam_dir

  String picard
 

  scatter (sample in inputSamples) {

	  call contamination_check {
	  	input:
	  		bam_dir=bam_dir,
	  		prefix = sample[0],
	  		verify_bamid = verify_bamid,
	  		contam_vcf = contam_vcf
	  }
	  
	  call coverage {
	  	input:
	  		picard = picard,
	  		prefix = sample[0],
	  		bam_dir=bam_dir,
	  		ref = ref,	
	  		targets = targets
	  }	


	  output {
	    Array[File] selfSM = contamination_check.selfSM
	    Array[File] depthSM = contamination_check.depthSM
	    Array[File] contam_log = contamination_check.contam_log
	    Array[File] hs_metrics = coverage.hs_metrics
	  }
  }
}

task contamination_check{
	String bam_dir
	String prefix
	String verify_bamid
	String contam_vcf
	

	command {
		${verify_bamid} --verbose --ignoreRG --vcf ${contam_vcf} --out ${prefix} --bam ${bam_dir}/${prefix}.bam
	}
	runtime {
            cpus: "4"
            requested_memory: "8000"
        }
	output {
		File selfSM = "${prefix}.selfSM"
		File depthSM = "${prefix}.depthSM"
		File contam_log = "${prefix}.log"
	}
}

task coverage{
	String picard
	String prefix
	String bam_dir
	String ref
	String targets

	command {
		java -Xmx6G -jar ${picard} CollectHsMetrics R=${ref} TARGET_INTERVALS=${targets} BAIT_INTERVALS=${targets} INPUT=${bam_dir}/${prefix}.bam OUTPUT=${prefix}.hs_metrics.txt
	}
	runtime {
            cpus: "4"
            requested_memory: "8000"
        }
	output {
		File hs_metrics = "${prefix}.hs_metrics.txt"
	}
}


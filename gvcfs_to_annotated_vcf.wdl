# This is a script for joint genotying, collecting variant metrics and annotating variants.
# Needs a list of g.vcf.gz with directories as an input.
# reference files and gatk/picard are defined as strings to avoid dealing with indices and copying files.
# Make sure that you have bwa, vcftools, perl, tabix and picard ready to be accessed from command line.
# For gatk and picard input string is specified in inputs.json.
# Tested with the following versions on Ruddle:
# GATK/3.8-0-Java-1.8.0_121, picard/2.9.0-Java-1.8.0_121, VCFtools/0.1.14-foss-2016a-Perl-5.22.1


workflow gvcf_to_vcf {

 

  String ref
  String eval_targets

  String inputSamples
  String prefix

  String gatk
  String picard

  String plugindir
  String vepdir
  String vepcache
  String refdir


    call joint_gt {
        input:
            gatk = gatk,
            ref = ref,
            prefix = prefix,
            input_gvcf = inputSamples
        }

    call collect_metrics{
        input:    
	    input_vcf = joint_gt.output_vcf,
            picard = picard,
            prefix = prefix,
	    eval_targets = eval_targets
    }

    call annotate{
        input:
            input_vcf = joint_gt.output_vcf,
            vepcache = vepcache,
            vepdir = vepdir,
            plugindir = plugindir,
            refdir = refdir,
            prefix = prefix
    }


          output {
            File vcf = joint_gt.output_vcf
            File vcf_index = joint_gt.output_vcf_index
            File metrics_details = collect_metrics.output_detail_metrics
            File metrics_summary = collect_metrics.output_summary_metrics
            File metrics_het = collect_metrics.output_het
            File metrics_relatedness = collect_metrics.output_relatedness
            File vep_vcf = annotate.output_vcf
            File vep_vcf_index = annotate.output_vcf_index
          }

}

task joint_gt{
        String ref
        String prefix
        String input_gvcf
	String gatk

        command {
            java -Xmx30G -jar ${gatk} -T GenotypeGVCFs -R ${ref} -V ${input_gvcf} -o ${prefix}.raw.vcf.gz
        }
        runtime {
            cpus: "8"
            requested_memory: "32000"
        }
        output {
            File output_vcf = "${prefix}.raw.vcf.gz"
            File output_vcf_index = "${prefix}.raw.vcf.gz.tbi"
        }
}

task collect_metrics{
        String picard
        String prefix
        String eval_targets
        File input_vcf

        command {
                java -Xmx14G -jar ${picard} CollectVariantCallingMetrics INPUT=${input_vcf} OUTPUT=${prefix} TARGET_INTERVALS=${eval_targets}

                vcftools --vcf ${input_vcf} --relatedness2 --out ${prefix}

                vcftools --vcf ${input_vcf} --chr X --from-bp 2699520 --to-bp 154931043 --het --out ${prefix}

        }
        output {
                File output_detail_metrics = "${prefix}.variant_calling_detail_metrics"
                File output_summary_metrics = "${prefix}.variant_calling_summary_metrics"
                File output_het = "${prefix}.het"
                File output_relatedness = "${prefix}.relatedness2"

        }
}

task annotate{
        String plugindir
        String vepdir
        String vepcache
        String refdir
        String prefix
        File input_vcf

        command {
                
                export PERL5LIB=$PERL5LIB:${plugindir}:${plugindir}/loftee

                perl ${vepdir}/variant_effect_predictor.pl  --tabix --everything --vcf --allele_number --no_stats \
     --cache --offline --dir_cache ${vepcache}/ --dir_plugins ${plugindir}/ --force_overwrite \
     --cache_version 85 --fasta ${vepcache}/homo_sapiens/85_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
     --assembly GRCh37 --tabix --plugin LoF,human_ancestor_fa:${plugindir}/human_ancestor.fa.gz,filter_position:0.05,min_intron_size:15,loftee_path:${plugindir}/loftee \
     --plugin dbNSFP,${refdir}/dbNSFPv2.9.gz,Polyphen2_HVAR_pred,CADD_phred,SIFT_pred,FATHMM_pred,MutationTaster_pred,MetaSVM_pred \
     -i ${input_vcf} -o ${prefix}.vep.vcf.gz

        }
        output {
                File output_vcf = "${prefix}.vep.vcf.gz"
                File output_vcf_index = "${prefix}.vep.vcf.gz.tbi"
        }
}



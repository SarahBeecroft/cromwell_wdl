import "cnv_common_tasks.wdl" as CNVTasks

workflow CNVGermlineCohortWorkflow {

	File ref_fasta
    File ref_fasta_fai
    File ref_fasta_dict

	File intervals
	Int num_intervals_per_scatter
	
	File bam_file_list
	Array[File] bam_files = read_lines(bam_file_list)

	String cohort_entity_id

	########################################################################
    #### optional arguments for DetermineGermlineContigPloidyCohortMode ####
    ########################################################################
	File contig_ploidy_priors
    Float? ploidy_mean_bias_standard_deviation
    Float? ploidy_mapping_error_rate
    Float? ploidy_global_psi_scale
    Float? ploidy_sample_psi_scale


    ############################################################
    #### optional arguments for GermlineCNVCallerCohortMode ####
    ############################################################
    Float? gcnv_p_alt
    Float? gcnv_p_active
    Float? gcnv_cnv_coherence_length
    Float? gcnv_class_coherence_length
    Int? gcnv_max_copy_number
    Int? mem_gb_for_germline_cnv_caller
    Int? cpu_for_germline_cnv_caller

    # optional arguments for germline CNV denoising model
    Int? gcnv_max_bias_factors
    Float? gcnv_mapping_error_rate
    Float? gcnv_interval_psi_scale
    Float? gcnv_sample_psi_scale
    Float? gcnv_depth_correction_tau
    Float? gcnv_log_mean_bias_standard_deviation
    Float? gcnv_init_ard_rel_unexplained_variance
    Int? gcnv_num_gc_bins
    Float? gcnv_gc_curve_standard_deviation
    String? gcnv_copy_number_posterior_expectation_mode
    Boolean? gcnv_enable_bias_factors
    Int? gcnv_active_class_padding_hybrid_mode

    # optional arguments for Hybrid ADVI
    Float? gcnv_learning_rate
    Float? gcnv_adamax_beta_1
    Float? gcnv_adamax_beta_2
    Int? gcnv_log_emission_samples_per_round
    Float? gcnv_log_emission_sampling_median_rel_error
    Int? gcnv_log_emission_sampling_rounds
    Int? gcnv_max_advi_iter_first_epoch
    Int? gcnv_max_advi_iter_subsequent_epochs
    Int? gcnv_min_training_epochs
    Int? gcnv_max_training_epochs
    Float? gcnv_initial_temperature
    Int? gcnv_num_thermal_advi_iters
    Int? gcnv_convergence_snr_averaging_window
    Float? gcnv_convergence_snr_trigger_threshold
    Int? gcnv_convergence_snr_countdown_window
    Int? gcnv_max_calling_iters
    Float? gcnv_caller_update_convergence_threshold
    Float? gcnv_caller_internal_admixing_rate
    Float? gcnv_caller_external_admixing_rate
    Boolean? gcnv_disable_annealing

    ###################################################
    #### arguments for PostprocessGermlineCNVCalls ####
    ###################################################
    Int ref_copy_number_autosomal_contigs
    Array[String]? allosomal_contigs

    scatter (bam in bam_files) {
        call CNVTasks.CollectCounts {
            input:
                intervals = intervals,
                bam = bam,
                ref_fasta = ref_fasta,
                ref_fasta_fai = ref_fasta_fai,
                ref_fasta_dict = ref_fasta_dict
        }
    }

    call DetermineGermlineContigPloidyCohortMode {
        input:
            cohort_entity_id = cohort_entity_id,
            intervals = intervals,
            read_count_files = CollectCounts.counts,
            contig_ploidy_priors = contig_ploidy_priors,
            mean_bias_standard_deviation = ploidy_mean_bias_standard_deviation,
            mapping_error_rate = ploidy_mapping_error_rate,
            global_psi_scale = ploidy_global_psi_scale,
            sample_psi_scale = ploidy_sample_psi_scale
    }

    call CNVTasks.ScatterIntervals {
        input:
            interval_list = intervals,
            num_intervals_per_scatter = num_intervals_per_scatter
    }

  	# annotated_intervals = AnnotateIntervals.annotated_intervals,

    scatter (scatter_index in range(length(ScatterIntervals.scattered_interval_lists))) {
        call GermlineCNVCallerCohortMode {
            input:
                scatter_index = scatter_index,
                cohort_entity_id = cohort_entity_id,
                read_count_files = CollectCounts.counts,
                contig_ploidy_calls_tar = DetermineGermlineContigPloidyCohortMode.contig_ploidy_calls_tar,
                intervals = ScatterIntervals.scattered_interval_lists[scatter_index],
                p_alt = gcnv_p_alt,
                p_active = gcnv_p_active,
                cnv_coherence_length = gcnv_cnv_coherence_length,
                class_coherence_length = gcnv_class_coherence_length,
                max_copy_number = gcnv_max_copy_number,
                max_bias_factors = gcnv_max_bias_factors,
                mapping_error_rate = gcnv_mapping_error_rate,
                interval_psi_scale = gcnv_interval_psi_scale,
                sample_psi_scale = gcnv_sample_psi_scale,
                depth_correction_tau = gcnv_depth_correction_tau,
                log_mean_bias_standard_deviation = gcnv_log_mean_bias_standard_deviation,
                init_ard_rel_unexplained_variance = gcnv_init_ard_rel_unexplained_variance,
                num_gc_bins = gcnv_num_gc_bins,
                gc_curve_standard_deviation = gcnv_gc_curve_standard_deviation,
                copy_number_posterior_expectation_mode = gcnv_copy_number_posterior_expectation_mode,
                enable_bias_factors = gcnv_enable_bias_factors,
                active_class_padding_hybrid_mode = gcnv_active_class_padding_hybrid_mode,
                learning_rate = gcnv_learning_rate,
                adamax_beta_1 = gcnv_adamax_beta_1,
                adamax_beta_2 = gcnv_adamax_beta_2,
                log_emission_samples_per_round = gcnv_log_emission_samples_per_round,
                log_emission_sampling_median_rel_error = gcnv_log_emission_sampling_median_rel_error,
                log_emission_sampling_rounds = gcnv_log_emission_sampling_rounds,
                max_advi_iter_first_epoch = gcnv_max_advi_iter_first_epoch,
                max_advi_iter_subsequent_epochs = gcnv_max_advi_iter_subsequent_epochs,
                min_training_epochs = gcnv_min_training_epochs,
                max_training_epochs = gcnv_max_training_epochs,
                initial_temperature = gcnv_initial_temperature,
                num_thermal_advi_iters = gcnv_num_thermal_advi_iters,
                convergence_snr_averaging_window = gcnv_convergence_snr_averaging_window,
                convergence_snr_trigger_threshold = gcnv_convergence_snr_trigger_threshold,
                convergence_snr_countdown_window = gcnv_convergence_snr_countdown_window,
                max_calling_iters = gcnv_max_calling_iters,
                caller_update_convergence_threshold = gcnv_caller_update_convergence_threshold,
                caller_internal_admixing_rate = gcnv_caller_internal_admixing_rate,
                caller_external_admixing_rate = gcnv_caller_external_admixing_rate,
                disable_annealing = gcnv_disable_annealing
        }
    }

    Array[Array[File]] call_tars_sample_by_shard = transpose(GermlineCNVCallerCohortMode.gcnv_call_tars)

    scatter (sample_index in range(length(CollectCounts.entity_id))) {
        call CNVTasks.PostprocessGermlineCNVCalls {
            input:
                entity_id = CollectCounts.entity_id[sample_index],
                gcnv_calls_tars = call_tars_sample_by_shard[sample_index],
                gcnv_model_tars = GermlineCNVCallerCohortMode.gcnv_model_tar,
                calling_configs = GermlineCNVCallerCohortMode.calling_config_json,
                denoising_configs = GermlineCNVCallerCohortMode.denoising_config_json,
                gcnvkernel_version = GermlineCNVCallerCohortMode.gcnvkernel_version_json,
                sharded_interval_lists = GermlineCNVCallerCohortMode.sharded_interval_list,
                contig_ploidy_calls_tar = DetermineGermlineContigPloidyCohortMode.contig_ploidy_calls_tar,
                allosomal_contigs = allosomal_contigs,
                ref_copy_number_autosomal_contigs = ref_copy_number_autosomal_contigs,
                sample_index = sample_index
        }
    }

    output {
        Array[File] read_counts = CollectCounts.counts
        File contig_ploidy_model_tar = DetermineGermlineContigPloidyCohortMode.contig_ploidy_model_tar
        File contig_ploidy_calls_tar = DetermineGermlineContigPloidyCohortMode.contig_ploidy_calls_tar
        Array[File] gcnv_model_tars = GermlineCNVCallerCohortMode.gcnv_model_tar
        Array[Array[File]] gcnv_calls_tars = GermlineCNVCallerCohortMode.gcnv_call_tars
        Array[File] gcnv_tracking_tars = GermlineCNVCallerCohortMode.gcnv_tracking_tar
        Array[File] genotyped_intervals_vcfs = PostprocessGermlineCNVCalls.genotyped_intervals_vcf
        Array[File] genotyped_segments_vcfs = PostprocessGermlineCNVCalls.genotyped_segments_vcf
    }
}


task DetermineGermlineContigPloidyCohortMode {
    String cohort_entity_id
    File? intervals
    Array[File] read_count_files
    File contig_ploidy_priors
    String? output_dir

    # Model parameters
    Float? mean_bias_standard_deviation
    Float? mapping_error_rate
    Float? global_psi_scale
    Float? sample_psi_scale

    # We do not expose Hybrid ADVI parameters -- the default values are decent

    # If optional output_dir not specified, use "out"
    String output_dir_ = select_first([output_dir, "out"])

    command <<<
        set -e
                source activate gatk

        mkdir ${output_dir_}
        export MKL_NUM_THREADS=8
        export OMP_NUM_THREADS=8

        gatk --java-options "-Xmx16000m"  DetermineGermlineContigPloidy \
            ${"-L " + intervals} \
            --input ${sep=" --input " read_count_files} \
            --contig-ploidy-priors ${contig_ploidy_priors} \
            --interval-merging-rule OVERLAPPING_ONLY \
            --output ${output_dir_} \
            --output-prefix ${cohort_entity_id} \
            --verbosity DEBUG \
            --mean-bias-standard-deviation ${default="0.01" mean_bias_standard_deviation} \
            --mapping-error-rate ${default="0.01" mapping_error_rate} \
            --global-psi-scale ${default="0.001" global_psi_scale} \
            --sample-psi-scale ${default="0.0001" sample_psi_scale}

        tar czf ${cohort_entity_id}-contig-ploidy-model.tar.gz -C ${output_dir_}/${cohort_entity_id}-model .
        tar czf ${cohort_entity_id}-contig-ploidy-calls.tar.gz -C ${output_dir_}/${cohort_entity_id}-calls .
    >>>

    runtime {
        cpus: 8
        requested_memory: 16000
    }

    output {
        File contig_ploidy_model_tar = "${cohort_entity_id}-contig-ploidy-model.tar.gz"
        File contig_ploidy_calls_tar = "${cohort_entity_id}-contig-ploidy-calls.tar.gz"
    }
}

task GermlineCNVCallerCohortMode {

    Int scatter_index
    String cohort_entity_id
    Array[File] read_count_files
    File contig_ploidy_calls_tar
    File intervals
    #File? annotated_intervals
    String? output_dir

    # Caller parameters
    Float? p_alt
    Float? p_active
    Float? cnv_coherence_length
    Float? class_coherence_length
    Int? max_copy_number

    # Denoising model parameters
    Int? max_bias_factors
    Float? mapping_error_rate
    Float? interval_psi_scale
    Float? sample_psi_scale
    Float? depth_correction_tau
    Float? log_mean_bias_standard_deviation
    Float? init_ard_rel_unexplained_variance
    Int? num_gc_bins
    Float? gc_curve_standard_deviation
    String? copy_number_posterior_expectation_mode
    Boolean? enable_bias_factors
    Int? active_class_padding_hybrid_mode

    # Hybrid ADVI parameters
    Float? learning_rate
    Float? adamax_beta_1
    Float? adamax_beta_2
    Int? log_emission_samples_per_round
    Float? log_emission_sampling_median_rel_error
    Int? log_emission_sampling_rounds
    Int? max_advi_iter_first_epoch
    Int? max_advi_iter_subsequent_epochs
    Int? min_training_epochs
    Int? max_training_epochs
    Float? initial_temperature
    Int? num_thermal_advi_iters
    Int? convergence_snr_averaging_window
    Float? convergence_snr_trigger_threshold
    Int? convergence_snr_countdown_window
    Int? max_calling_iters
    Float? caller_update_convergence_threshold
    Float? caller_internal_admixing_rate
    Float? caller_external_admixing_rate
    Boolean? disable_annealing


    # If optional output_dir not specified, use "out"
    String output_dir_ = select_first([output_dir, "out"])
    Int num_samples = length(read_count_files)

    String dollar = "$" #WDL workaround, see https://github.com/broadinstitute/cromwell/issues/1819

    # ${"--annotated-intervals " + annotated_intervals} \

    command <<<
        set -e
		#module load GATK/4.1.0.0-Java-1.8.0_121
		#module load Python/miniconda
		source activate gatk

        mkdir ${output_dir_}
        export MKL_NUM_THREADS=8
        export OMP_NUM_THREADS=8

        mkdir contig-ploidy-calls-dir
        tar xzf ${contig_ploidy_calls_tar} -C contig-ploidy-calls-dir

        gatk --java-options "-Xmx15000m"  GermlineCNVCaller \
            --run-mode COHORT \
            -L ${intervals} \
            --input ${sep=" --input " read_count_files} \
            --contig-ploidy-calls contig-ploidy-calls-dir \
            --interval-merging-rule OVERLAPPING_ONLY \
            --output ${output_dir_} \
            --output-prefix ${cohort_entity_id} \
            --verbosity DEBUG \
            --p-alt ${default="1e-6" p_alt} \
            --p-active ${default="1e-2" p_active} \
            --cnv-coherence-length ${default="10000.0" cnv_coherence_length} \
            --class-coherence-length ${default="10000.0" class_coherence_length} \
            --max-copy-number ${default="5" max_copy_number} \
            --max-bias-factors ${default="5" max_bias_factors} \
            --mapping-error-rate ${default="0.01" mapping_error_rate} \
            --interval-psi-scale ${default="0.001" interval_psi_scale} \
            --sample-psi-scale ${default="0.0001" sample_psi_scale} \
            --depth-correction-tau ${default="10000.0" depth_correction_tau} \
            --log-mean-bias-standard-deviation ${default="0.1" log_mean_bias_standard_deviation} \
            --init-ard-rel-unexplained-variance ${default="0.1" init_ard_rel_unexplained_variance} \
            --num-gc-bins ${default="20" num_gc_bins} \
            --gc-curve-standard-deviation ${default="1.0" gc_curve_standard_deviation} \
            --copy-number-posterior-expectation-mode ${default="HYBRID" copy_number_posterior_expectation_mode} \
            --enable-bias-factors ${default="true" enable_bias_factors} \
            --active-class-padding-hybrid-mode ${default="50000" active_class_padding_hybrid_mode} \
            --learning-rate ${default="0.05" learning_rate} \
            --adamax-beta-1 ${default="0.9" adamax_beta_1} \
            --adamax-beta-2 ${default="0.99" adamax_beta_2} \
            --log-emission-samples-per-round ${default="50" log_emission_samples_per_round} \
            --log-emission-sampling-median-rel-error ${default="0.005" log_emission_sampling_median_rel_error} \
            --log-emission-sampling-rounds ${default="10" log_emission_sampling_rounds} \
            --max-advi-iter-first-epoch ${default="5000" max_advi_iter_first_epoch} \
            --max-advi-iter-subsequent-epochs ${default="100" max_advi_iter_subsequent_epochs} \
            --min-training-epochs ${default="10" min_training_epochs} \
            --max-training-epochs ${default="100" max_training_epochs} \
            --initial-temperature ${default="2.0" initial_temperature} \
            --num-thermal-advi-iters ${default="2500" num_thermal_advi_iters} \
            --convergence-snr-averaging-window ${default="500" convergence_snr_averaging_window} \
            --convergence-snr-trigger-threshold ${default="0.1" convergence_snr_trigger_threshold} \
            --convergence-snr-countdown-window ${default="10" convergence_snr_countdown_window} \
            --max-calling-iters ${default="10" max_calling_iters} \
            --caller-update-convergence-threshold ${default="0.001" caller_update_convergence_threshold} \
            --caller-internal-admixing-rate ${default="0.75" caller_internal_admixing_rate} \
            --caller-external-admixing-rate ${default="1.00" caller_external_admixing_rate} \
            --disable-annealing ${default="false" disable_annealing}

        tar czf ${cohort_entity_id}-gcnv-model-shard-${scatter_index}.tar.gz -C ${output_dir_}/${cohort_entity_id}-model .
        tar czf ${cohort_entity_id}-gcnv-tracking-shard-${scatter_index}.tar.gz -C ${output_dir_}/${cohort_entity_id}-tracking .

        CURRENT_SAMPLE=0
        NUM_SAMPLES=${num_samples}
        NUM_DIGITS=${dollar}{#NUM_SAMPLES}
        while [ $CURRENT_SAMPLE -lt $NUM_SAMPLES ]; do
            CURRENT_SAMPLE_WITH_LEADING_ZEROS=$(printf "%0${dollar}{NUM_DIGITS}d" $CURRENT_SAMPLE)
            tar czf ${cohort_entity_id}-gcnv-calls-shard-${scatter_index}-sample-$CURRENT_SAMPLE_WITH_LEADING_ZEROS.tar.gz -C ${output_dir_}/${cohort_entity_id}-calls/SAMPLE_$CURRENT_SAMPLE .
            let CURRENT_SAMPLE=CURRENT_SAMPLE+1
        done
    >>>

    runtime {
        cpus: 8
        requested_memory: 16000
    }

    output {
        File gcnv_model_tar = "${cohort_entity_id}-gcnv-model-shard-${scatter_index}.tar.gz"
        Array[File] gcnv_call_tars = glob("${cohort_entity_id}-gcnv-calls-shard-${scatter_index}-sample-*.tar.gz")
        File gcnv_tracking_tar = "${cohort_entity_id}-gcnv-tracking-shard-${scatter_index}.tar.gz"
        File calling_config_json = "${output_dir_}/${cohort_entity_id}-calls/calling_config.json"
        File denoising_config_json = "${output_dir_}/${cohort_entity_id}-calls/denoising_config.json"
        File gcnvkernel_version_json = "${output_dir_}/${cohort_entity_id}-calls/gcnvkernel_version.json"
        File sharded_interval_list = "${output_dir_}/${cohort_entity_id}-calls/interval_list.tsv"
    }
}









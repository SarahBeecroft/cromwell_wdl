#!/bin/bash
#SBATCH -n 1
#SBATCH -c 8
#SBATCH -J launch_cromwell
#SBATCH --mem=64000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/shared/tools/jars/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/gatk4_multisample/Multisample_Fastq_to_Gvcf_GATK4.wdl \
-i /gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/gatk4_multisample/Multisample_Fastq_to_Gvcf_GATK4_inputs.json \
-o /gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/gatk4_multisample/cromwell.options

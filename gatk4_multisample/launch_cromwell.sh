#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J launch_cromwell
#SBATCH --mem=8000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/sp2249/cromwell/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/Multisample_Fastq_to_Gvcf_GATK4.wdl \
-i /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/Multisample_Fastq_to_Gvcf_GATK4_inputs.json \
-o /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/cromwell.options

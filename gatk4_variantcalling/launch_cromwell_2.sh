#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J launch_cromwell
#SBATCH --mem=8000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/sp2249/cromwell/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_variantcalling/Ruddle_joint-discovery-gatk4-local.wdl \
-i /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_variantcalling/Ruddle_joint-discovery-gatk4-local_inputs.json  \
-o /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_variantcalling/cromwell.options

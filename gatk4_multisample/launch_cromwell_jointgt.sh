#!/bin/bash
#SBATCH -n 1
#SBATCH -c 8
#SBATCH -J launch_cromwell
#SBATCH --mem=64000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/sp2249/cromwell/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/cromwell-36.jar run \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/Multisample_joint_GATK4.wdl \
-i /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/Multisample_joint_GATK4_inputs.json \
-o /gpfs/ycga/project/ysm/lek/sp2249/cromwell/gatk4_multisample/cromwell.options

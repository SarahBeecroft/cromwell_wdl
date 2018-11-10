#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -J launch_cromwell
#SBATCH --mem=8000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/sp2249/cromwell/slurm.conf -jar \
/gpfs/ycga/project/ysm/lek/sp2249/cromwell/cromwell-36.jar run \
/gpfs/ycga/scratch60/ysm/lek/sp2249/test/Ruddle_processing-for-variant-discovery-gatk4.wdl \
-i /gpfs/ycga/scratch60/ysm/lek/sp2249/test/Ruddle_processing-for-variant-discovery-gatk4_inputs.json \
-o /gpfs/ycga/scratch60/ysm/lek/sp2249/test/options.options

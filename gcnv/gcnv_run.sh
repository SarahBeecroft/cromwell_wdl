#!/bin/bash
#SBATCH -c 8
#SBATCH -J launch_cromwell
#SBATCH --mem=32000

java -Dconfig.file=/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/slurm.conf \
-jar /gpfs/ycga/project/ysm/lek/shared/tools/jars/cromwell-36.jar \
run /home/sp2249/project/gcnv/cnv_germline_cohort_workflow.wdl \
-i /home/sp2249/project/gcnv/cnv_germline_cohort_workflow.json \
-o cromwell.options

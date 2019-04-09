# gCNV pipeline 

**adapted for using on slurm HPC (e.g. Ruddle in Yale)**

This wdl is modification from the Broad Institutes wdl https://github.com/broadinstitute/gatk/tree/master/scripts/cnv_wdl/germline

## Prerequisites

You need to install virtual environment for gatk4. For instructions see: https://software.broadinstitute.org/gatk/documentation/article?id=12836

On Ruddle the commands would be:

```
module load Python/miniconda
conda env create -f gatkcondaenv.yml
source activate gatk
```


#!/usr/bin/bash -l
#SBATCH -p short -c 24 -N 1 -n 1 --mem 64gb --out logs/phyling_align.log

module load phyling
CPU=96
if  [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
phyling align -I input -m fungi_odb10 -t $CPU -o fungi_phyling_align -v 


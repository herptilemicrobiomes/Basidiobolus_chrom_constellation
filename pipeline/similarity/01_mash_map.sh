#!/usr/bin/bash -l
#SBATCH -p short -C cascade -c 48 --mem 32gb --out logs/mashmap.log

#hardcode for now
THREADS=8
PARALLEL=6
# this is pretty fast don't need separate jobs
module load mashmap
OUTDIR=results/similarity_mashmap
mkdir -p $OUTDIR

ls input/*.fasta > genome_list.txt
parallel -j $PARALLEL mashmap -t $THREADS --dropLowMapId --reportPercentage -q {1} -r {2} --dense -o $OUTDIR/{1/.}_vs_{2/.}.paf ::: $(cat genome_list.txt) ::: $(cat genome_list.txt)

module load bcftools
parallel -j $THREADS bgzip -f {} ::: $(ls $OUTDIR/*.paf)

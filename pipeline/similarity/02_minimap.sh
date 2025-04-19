#!/usr/bin/bash -l
#SBATCH -p short -C cascade -c 96 --mem 128gb --out logs/minimap.log

#hardcode for now
THREADS=8
PARALLEL=12
# this is pretty fast don't need separate jobs
module load minimap2
OUTDIR=results/similarity_minimap
mkdir -p $OUTDIR

ls input/*.fasta > genome_list.txt
#parallel -j $PARALLEL minimap2 -x asm20 --cs=long -t $THREADS -o $OUTDIR/{1/.}_vs_{2/.}.minimap2_long.paf {1} {2} ::: $(cat genome_list.txt) ::: $(cat genome_list.txt)

parallel -j $PARALLEL minimap2 -x asm20 -t $THREADS -o $OUTDIR/{2/.}_vs_{1/.}.paf {1} {2} ::: $(cat genome_list.txt) ::: $(cat genome_list.txt)

module load bcftools
parallel -j $PARALLEL bgzip -f {} ::: $(ls $OUTDIR/*.paf)

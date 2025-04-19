#!/usr/bin/bash -l
#SBATCH -p short -C cascade -c 96 --mem 128gb --out logs/minimap_purge.log

#hardcode for now
THREADS=8
PARALLEL=12
# this is pretty fast don't need separate jobs
module load minimap2
OUTDIR=results/similarity_minimap_purged
mkdir -p $OUTDIR

ls results/contam_reports/*.fasta > genome_list_purged.txt
#parallel -j $PARALLEL minimap2 -x asm20 --cs=long -t $THREADS -o $OUTDIR/{1/.}_vs_{2/.}.minimap2_long.paf {1} {2} ::: $(cat genome_list.txt) ::: $(cat genome_list.txt)

parallel -j $PARALLEL minimap2 -x asm20 -t $THREADS -o $OUTDIR/{2/.}_vs_{1/.}.paf {1} {2} ::: $(cat genome_list_purged.txt) ::: $(cat genome_list_purged.txt)

module load bcftools
parallel -j $PARALLEL bgzip -f {} ::: $(ls $OUTDIR/*.paf)

for file in $(ls $OUTDIR/*.paf.gz); do
    m=$(echo $file | sed 's/.purge//g')
    mv $file $m
done
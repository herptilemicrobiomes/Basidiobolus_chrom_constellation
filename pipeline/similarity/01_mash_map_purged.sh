#!/usr/bin/bash -l
#SBATCH -p short -C cascade -c 48 --mem 32gb --out logs/mashmap_purge.log

#hardcode for now
THREADS=8
PARALLEL=6
# this is pretty fast don't need separate jobs
module load mashmap
OUTDIR=results/similarity_mashmap_purged
mkdir -p $OUTDIR

ls results/contam_reports/*.fasta > genome_list_purged.txt

parallel -j $PARALLEL mashmap -t $THREADS --dropLowMapId --reportPercentage -q {1} -r {2} --dense -o $OUTDIR/{1/.}_vs_{2/.}.paf ::: $(cat genome_list_purged.txt) ::: $(cat genome_list_purged.txt)

module load bcftools
parallel -j $THREADS bgzip -f {} ::: $(ls $OUTDIR/*.paf)
for file in $(ls $OUTDIR/*.paf.gz); do
    m=$(echo $file | sed 's/.purge//g')
    mv $file $m
done
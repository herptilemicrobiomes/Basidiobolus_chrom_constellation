#!/usr/bin/bash -l
#SBATCH -p short -c 16 --mem 4gb 
module load samtools
module load bcftools
module load parallel

parallel -j 8 bgzip -fk {} ::: $(ls *.fasta)
parallel -j 8 samtools faidx {} ::: $(ls *.fasta.gz)


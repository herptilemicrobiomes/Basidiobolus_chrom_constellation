#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 4 --mem 24gb  --out logs/find_telomeres.log

module load parallel

mkdir -p telomere_reports
for a in $(ls input/*.gz)
do
	pigz -dc $a > $SCRATCH/$(basename $a .gz)
done
ls $SCRATCH/*.fasta | parallel -j 4 python scripts_Hiltunen/find_telomeres.py {} \> telomere_reports/{/.}.telomere_report.txt

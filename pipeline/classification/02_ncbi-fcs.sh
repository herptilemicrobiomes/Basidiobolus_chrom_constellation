#!/usr/bin/bash -l
#SBATCH --mem 512gb -N 1 -n 1 -c 64 --out logs/fcs_classify.purge.log

module load AAFTF
hostname
rsync -a --progress /srv/projects/db/ncbi-fcs/0.5.4/gxdb /dev/shm/
#Fungi
TAXID=4859
INDIR=input
OUTDIR=results/contam_reports
mkdir -p $OUTDIR
parallel -j 8 AAFTF fcs_gx_purge  --db /dev/shm/gxdb/all  -i {} --cpus 8 -o $OUTDIR/{/.}.purge.fasta -t ${TAXID} -w $OUTDIR/{/.}.report ::: $(ls -U $INDIR/*.fasta)

rm -rf /dev/shm/gxdb

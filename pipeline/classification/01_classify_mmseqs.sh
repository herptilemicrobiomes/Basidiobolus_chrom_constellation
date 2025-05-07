#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 64 -C ryzen -n 1 --mem 255gb --out logs/mmseqs_classify.%a.log -J classify

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

module load mmseqs2
module load workspace/scratch
SAMPFILE=samples.csv
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
DB=/srv/projects/db/ncbi/mmseqs/uniref50
#DB=/srv/projects/db/ncbi/mmseqs/swissprot
DBNAME=$(basename $DB)

IFS=,
INPUT=input
OUTFOLDER=results/classify_mmseqs
mkdir -p $OUTFOLDER

cat $SAMPFILE | sed -n ${N}p | while read STRAIN FILENAME
do
	PREFIX=$(basename $FILENAME .fasta.gz)
  	mmseqs touchdb $DB
  	GENOME=$INPUT/$FILENAME
  	OUT=$OUTFOLDER/${PREFIX}/${DBNAME}
  	mkdir -p $OUTFOLDER/$PREFIX
  	if [ ! -s ${OUT}_tophit_aln ]; then
      		mmseqs easy-taxonomy $GENOME $DB $OUT $SCRATCH --threads $CPU --lca-ranks kingdom,phylum,family  --tax-lineage 1 --db-load-mode 2
  	fi
done

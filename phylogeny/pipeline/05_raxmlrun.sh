#!/usr/bin/bash -l
#SBATCH -p epyc -c 20 --mem 128gb --out logs/fungi5k_raxml.log

module load raxml-ng
CPU=20 # so I ran the parse code manually to figure out the optimal number of CPUs for this raxml run - see the results from raxml-ng --parse
pushd fungi_msa_filter-buildtree

IN=UHM_Basidiobolus_v1.fungi.fa
MODEL=$IN.part.aic
MSA=$IN.raxml.rba

raxml-ng --parse --msa $IN --model $MODEL

raxml-ng --all --msa $MSA --tree pars{10} -d aa --bs-trees 200 --threads auto{$CPU} --workers auto{4}

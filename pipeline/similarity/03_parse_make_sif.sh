#!/usr/bin/bash -l
#SBATCH -p short -c 2 --mem 4gb --out logs/parse_make_sif.log

./scripts/build_chromcluster.py -i results/similarity_mashmap \
    -o results/chrom_network/chrom_mashmap.minset.connections_w_singleton.sif \
    -s samples_min1.csv

pigz -kf results/chrom_network/chrom_mashmap.minset.connections_w_singleton.sif

./scripts/build_chromcluster.py -i results/similarity_minimap \
    -o results/chrom_network/chrom_minimap.minset.connections_w_singleton.sif \
    -s samples_min1.csv
pigz -kf results/chrom_network/chrom_minimap.minset.connections_w_singleton.sif

./scripts/build_chromcluster.py -i results/similarity_minimap_purged \
    -o results/chrom_network/chrom_minimap_purged.minset.connections_w_singleton.sif \
    -s samples_min1.csv

./scripts/build_chromcluster.py -i results/similarity_mashmap_purged \
    -o results/chrom_network/chrom_mashmap_purged.minset.connections_w_singleton.sif \
    -s samples_min1.csv
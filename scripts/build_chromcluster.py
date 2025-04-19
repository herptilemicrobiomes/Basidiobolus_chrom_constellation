#!/usr/bin/env python3

# build chromosome graph data for cytoscape from the minimap or maashmap output paf

import argparse
import os
import csv
import gzip

def process_paf(names, inputdir, outfile, extension, min_aligned, ignore_self):
    """
    Process the PAF files in the input directory and build the chromosome graph data.

    https://manual.cytoscape.org/en/latest/Supported_Network_File_Formats.html
    The simple interaction format is convenient for building a graph from a list of interactions. It also makes it easy to combine different interaction sets into a larger network, or add new interactions to an existing data set. The main disadvantage is that this format does not include any layout information, forcing Cytoscape to re-compute a new layout of the network each time it is loaded.
 
    Lines in the SIF file specify a source node, a relationship type (or edge type), and one or more target nodes:

    ```
    nodeA <relationship type> nodeB
    nodeC <relationship type> nodeA
    nodeD <relationship type> nodeE nodeF nodeB
    nodeG
    ...
    nodeY <relationship type> nodeZ
    ```

    A more specific example is:

    ```
    node1 typeA node2
    node2 typeB node3 node4 node5
    node0
    ```
    """

    with open(outfile, "w") as out:
#        outwrite = csv.writer(out, delimiter="\t", quoting=csv.QUOTE_MINIMAL)
        # 
        seen = {}
        for sample_id_a, sample_file_a in names.items():
            # make this a little more saavy in future, like strip the .gz and then also the .fasta dynamically in case 
            # extension is .fa or fas etc
            file_a_noextension = sample_file_a.replace('.fasta.gz','')
            for sample_id_b, sample_file_b in names.items():
                file_b_noextension = sample_file_b.replace('.fasta.gz','')
                print(f"Processing {sample_id_a} vs {sample_id_b}")
                paf_file = os.path.join(inputdir,f"{file_a_noextension}_vs_{file_b_noextension}.{extension}")
                if not os.path.exists(paf_file):
                    print(f"Error: PAF file {paf_file} does not exist.")
                    continue
                with gzip.open(paf_file, "rt") as paf:
                    pafparse = csv.reader(paf, delimiter="\t")
                    i = 0
                    for pafline in pafparse:
                        q = pafline[0]
                        qlen = int(pafline[1])
                        qstart = int(pafline[2])
                        qend = int(pafline[3])
                        strand = pafline[4]
                        t = pafline[5]
                        tlen = int(pafline[6])
                        tstart = int(pafline[7])
                        tend = int(pafline[8])

                        q = f'{sample_id_a}__{q}'
                        t = f'{sample_id_b}__{t}'

                        if q == t:
                            # ignore self connections to same contig
                            continue
                        # always create storage for the contig
                        # but we will not store a connection if
                        # it is too short
                        # and will avoid same-org self connections
                        # if that flag is set
                        if q not in seen:
                            seen[q] = set()
                        frac_aligned = (qend - qstart ) / qlen
                        if frac_aligned < min_aligned:
                            continue
                        if ignore_self and sample_id_a == sample_id_b:
                            # ignore self connections
                            continue
                        seen[q].add(t)
                        i += 1
        for q in sorted(seen):
            if len(seen[q]) == 0:
                out.write(f'{q}\n')
            else:
                matches = "\t".join(seen[q])
                out.write(f'{q}\tconnected_to\t{matches}\n')


def main():
    parser = argparse.ArgumentParser(description="Build chromosome graph data for Cytoscape from the minimap or maashmap output paf")
    parser.add_argument("--input", '-i', default="results/similarity_minimap", help="Input PAF folder")
    parser.add_argument("--samples", "-s", default="samples.csv",help="Input Samples file")
    parser.add_argument("--output", "-o", default="results/chrom_network/chrom.connections.sif", help="Output file name")
    parser.add_argument("--extension", default="paf.gz", help="PAF file name extension")
    parser.add_argument("--min-aligned", type=float, default=0.50, help="Minimum aligned fraction")
    parser.add_argument("--ignore-self", action="store_true", default=False, help="Ignore self connections")    
#    parser.add_argument("--minimap", action="store_true", default-True, help="Use minimap2 output format")
#    parser.add_argument("--maashmap", action="store_true", default=False, help="Use maashmap output format")
    args = parser.parse_args()

    dirname = os.path.dirname(args.output)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    if not os.path.exists(args.input):
        print(f"Error: Input dir {args.input} does not exist.")
        return

    if not os.path.exists(args.samples):
        print(f"Error: Input file {args.samples} does not exist.")
        return

#    if args.minimap and args.maashmap:
#        print("Error: Please specify either --minimap or --maashmap, not both.")
#        return

#    if not args.minimap and not args.maashmap:
#        print("Error: Please specify either --minimap or --maashmap.")
#        return

    # Read the PAF file and build the chromosome graph
    samplenames = {}
    with open(args.samples, "r") as sample_file:
        sampcsv = csv.reader(sample_file,delimiter=",")
        for row in sampcsv:
            if len(row) < 2:
                print(f"Error: Invalid row in samples file: {row}")
                continue
            sample_id = row[0]
            sample_file = row[1]
            samplenames[sample_id] = sample_file
    process_paf(samplenames, args.input, args.output, args.extension, args.min_aligned, args.ignore_self)


main()
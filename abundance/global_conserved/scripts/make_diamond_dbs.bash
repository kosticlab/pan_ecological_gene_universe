#!/bin/bash
source activate /home/sez10/miniconda3/envs/meta_assemblers

for my_fasta in /n/scratch3/users/b/btt5/orfletonv2/clustered_data/pan/all_seqs_rep_30_collapsed_cluster.fasta_*
do
    diamond makedb --in ${my_fasta} -d ${my_fasta}_db
done

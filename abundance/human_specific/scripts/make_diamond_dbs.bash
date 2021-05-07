#!/bin/bash
source activate /home/sez10/miniconda3/envs/meta_assemblers
fasta_file_list=${1}
IFS=',' read -ra fasta_file_array <<< "$fasta_file_list"

for i in "${!fasta_file_array[@]}"; do
    my_fasta="${fasta_file_array[${i}]}"
    diamond makedb --in ${my_fasta} -d ${my_fasta}_db
done

#!/bin/bash

input_path=${1}
database=${2}
prev_sample_types=${3}
gene_mapping=${4}
output_folder=${5}
split_number=${6}

geneNumber=$(wc -l ${gene_mapping} | awk '{print $1}')

echo ${geneNumber}
echo ${split_number}
lastCount=0
for (( COUNTER=${split_number}; COUNTER<=${geneNumber}; COUNTER+=${split_number} )); do
    lastCount=${COUNTER}
    sbatch -c 1 -p short --mem=50G -t 0-10:00 /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/figure5_human_specific_universal_genes/code_to_do_human_vs_all/get_pval_in_chunks_human_vs_all.bash ${input_path} ${database} ${prev_sample_types} ${gene_mapping} ${output_folder} ${split_number} ${COUNTER}
done
num1="$(($geneNumber-$lastCount))"
sbatch -c 1 -p short --mem=50G -t 0-10:00 /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/figure5_human_specific_universal_genes/code_to_do_human_vs_all/get_pval_in_chunks_human_vs_all.bash ${input_path} ${database} ${prev_sample_types} ${gene_mapping} ${output_folder} ${num1} ${geneNumber}


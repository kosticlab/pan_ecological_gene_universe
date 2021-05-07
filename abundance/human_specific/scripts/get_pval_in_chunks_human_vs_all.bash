#!/bin/bash

input_path=${1}
database=${2}
prev_sample_types=${3}
gene_mapping=${4}
output_folder=${5}
split_number=${6}
COUNTER=${7}

source activate r_env

Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/figure5_human_specific_universal_genes/code_to_do_human_vs_all/get_pval_in_chunks_human_vs_all.R ${input_path} ${database} ${prev_sample_types} ${gene_mapping} ${output_folder} ${split_number} ${COUNTER}

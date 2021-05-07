#!/bin/bash
input_path=${1}
database=${2}
prev_sample_types=${3}
gene_mapping=${4}
output_folder=${5}

source activate r_env

Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/gene_abundances/code_all_pvals/get_all_pvals.R ${input_path} ${database} ${prev_sample_types} ${gene_mapping} ${output_folder}

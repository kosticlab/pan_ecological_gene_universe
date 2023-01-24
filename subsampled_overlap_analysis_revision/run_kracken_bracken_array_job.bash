#!/bin/bash

input_file=${1}
thread_number=${2}
output_folder=${3}
kracken_db=${4}
adapter_file=${5}
bitmask_file=${6}
srprism_files=${7}
tmp_folder=${8}

input_line=$(awk "NR==${SLURM_ARRAY_TASK_ID}" ${input_file})
sample=$(echo $input_line | awk '{print $1}')
category=$(echo $input_line | awk '{print $3}')

echo ${sample}
echo ${category}

./scripts/run_kracken_bracken.bash ${sample} ${category} 5 kracken_ouptut /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/kraken2_db /n/data1/joslin/icrb/kostic/szimmerman/files_for_gene_catalogue/adapters.fa /n/data1/joslin/icrb/kostic/szimmerman/files_for_gene_catalogue/GRCh38/GRCh38.primary_assembly.genome.bitmask /n/data1/joslin/icrb/kostic/szimmerman/files_for_gene_catalogue/GRCh38/GRCh38.primary_assembly.genome.srprism tmp

#!/bin/bash

input_file=${1}
core_number=${2}
output_dir=${3}

file=$(awk "NR==${SLURM_ARRAY_TASK_ID}" ${input_file})

/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/run_CAT.bash ${file} ${core_number} ${output_dir}

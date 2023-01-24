#!/bin/bash

input_file=${1}
threads=${2}
output_dir=${3}

while read line
do
/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/annotate_CAT.bash ${line} ${threads} ${output_dir}
done < ${input_file}

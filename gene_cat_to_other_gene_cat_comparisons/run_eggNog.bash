#!/bin/bash

source activate eggNogMapper

input_fasta=${1}
thread_number=${2}
database_folder=${3}
output_dir=${4}
tmp_dir=${5}
out_prefix=${6}
input_type=${7}

mkdir -p ${output_dir}
mkdir -p ${tmp_dir}


emapper.py -i ${input_fasta} --itype proteins --data_dir ${database_folder} --cpu ${thread_number} --output_dir ${output_dir} --temp_dir ${tmp_dir} --output ${out_prefix}


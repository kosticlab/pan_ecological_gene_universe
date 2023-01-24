#!/bin/bash

input_file=${1}
output_prefix=${2}
thread_number=${3}
hmm_db=${4}
num_sequences=${5}

#source activate /home/sez10/miniconda3_2/envs/interproscan
source activate hmmer_3_3_2

hmmsearch -Z ${num_sequences} -o ${output_prefix}_hmmout.txt --tblout ${output_prefix}_hmmout_table.txt --cpu ${thread_number} --incE 0.01 -E 1 ${hmm_db} ${input_file}

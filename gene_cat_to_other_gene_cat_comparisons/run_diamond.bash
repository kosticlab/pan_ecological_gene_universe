#!/bin/bash

source activate /home/sez10/miniconda3/envs/meta_assemblers

reference_db=${1}
query=${2}
output=${3}
thread_number=${4}


diamond blastp -d ${reference_db} -q ${query} -o ${output} --threads ${thread_number}

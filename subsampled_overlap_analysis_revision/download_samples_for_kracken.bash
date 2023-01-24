#!/bin/bash

run=${1}
thread_number=${2}
output_folder=${3}
module load sratoolkit/2.10.7

prefetch --max-size 200G -O ${output_folder} ${run}
fasterq-dump -O ${output_folder} --threads ${thread_number} ${output_folder}/${run}.sra

rm ${output_folder}/${run}.sra

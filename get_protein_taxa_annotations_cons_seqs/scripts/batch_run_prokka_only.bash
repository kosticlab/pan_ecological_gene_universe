#!/bin/bash
output_folder=${2}
thread_number=${3}

while read line
do
FILE_NAMES=$(echo $line | awk '{print $1}')
FOLDER_NAMES=$(echo $line | awk '{print $2}')
sbatch -p medium -c 4 --mem=30GB --requeue -t 1-00:00 /home/sez10/kostic_lab/gene_catalogue/run_prokka_only/run_prokka_only2.bash ${FILE_NAMES} ${FOLDER_NAMES} ${output_folder} ${thread_number}
done < ${1}

#!/bin/bash
output_folder=${2}
adapters_reference=${3}
bitmask_file=${4}
sprism_file=${5}
temp_dir=${6}
thread_number=${7}

while read line
do
SAMPLE_NAME=$(echo $line | awk '{print $1}')
FILE_NAMES=$(echo $line | awk '{print $2}')
sbatch -p medium -c 8 --mem=100GB --requeue -t 2-00:00 /home/sez10/kostic_lab/gene_catalogue/sampling_code/run_pipeline_megahit_only.bash $SAMPLE_NAME $FILE_NAMES ${output_folder} ${adapters_reference} ${bitmask_file} ${sprism_file} ${temp_dir} ${thread_number}
done < ${1}

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
sbatch -p short -c 8 --mem=50GB --requeue -t 0-11:59 run_pipeline.bash $SAMPLE_NAME $FILE_NAMES ${output_folder} ${adapters_reference} ${bitmask_file} ${sprism_file} ${temp_dir} ${thread_number}
done < ${1}


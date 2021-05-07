#!/bin/bash
##SBATCH -p short
##SBATCH -c 1
##SBATCH --mem=10GB
##SBATCH --requeue
##SBATCH -t 0-11:00
####SBATCH --array=1-250%40

LINE=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${1})
SAMPLE_NAME=$(echo $LINE | awk '{print $1}')
SAMPLE_TYPE=$(echo $LINE | awk '{print $2}')
echo ${SAMPLE_NAME}
echo ${SAMPLE_TYPE}
output_folder=${2}
temp_dir=${3}
thread_number=${4}
diamond_db=${5}
diamond_fastq=${6}

/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/gene_abundances/align_OV2_intersections_withdups.bash ${SAMPLE_NAME} ${output_folder}/${SAMPLE_TYPE}_samples_output ${temp_dir} ${temp_dir} ${diamond_db} ${diamond_fastq}

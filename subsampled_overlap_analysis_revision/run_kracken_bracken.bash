#!/bin/bash

run=${1}
category=${2}
thread_number=${3}
output_folder=${4}
DBNAME=${5} # /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/kraken2_db
adapters_reference=${6}
bitmask_file=${7}
sprism_file=${8}
temp_dir=${9}

module load sratoolkit/2.10.7

prefetch --max-size 200G -O ${output_folder} ${run}
fasterq-dump -O ${output_folder} --threads ${thread_number} ${output_folder}/${run}.sra
rm ${output_folder}/${run}.sra
fastq1_raw=${output_folder}/${run}.sra_1.fastq
fastq2_raw=${output_folder}/${run}.sra_2.fastq
# remove adapters

source activate /home/sez10/miniconda3/envs/meta_assemblers

bbduk.sh -Xmx8g in1=${fastq1_raw} in2=${fastq2_raw} out1=${output_folder}/${run}_1.trimmed.fastq out2=${output_folder}/${run}_2.trimmed.fastq ref=${adapters_reference} threads=${thread_number} qin=33 ktrim=r k=23 mink=11 hdist=1 tpe tbo
rm ${fastq1_raw}
rm ${fastq2_raw}

fastq1=${output_folder}/${run}_1.trimmed.fastq
fastq2=${output_folder}/${run}_2.trimmed.fastq
if [[ $category == "human" ]]
then
bmtagger.sh -b ${bitmask_file} -x ${sprism_file} -T ${temp_dir} -q1 -1 ${output_folder}/${run}_1.trimmed.fastq -2 ${output_folder}/${run}_2.trimmed.fastq -o ${output_folder}/${run}_human_free -X
rm ${fastq1}
rm ${fastq2}
fastq1=${output_folder}/${run}_human_free_1.fastq
fastq2=${output_folder}/${run}_human_free_2.fastq
fi

echo ${fastq1}
echo ${fastq2}

conda deactivate

/home/sez10/kostic_lab/software/kraken2_2.1.2_scripts/kraken2 --threads ${thread_number} --db $DBNAME --report ${output_folder}/${run}.k2report --paired ${fastq1} ${fastq2} > ${output_folder}/${run}.kraken2

rm ${fastq1}
rm ${fastq2}

/home/sez10/kostic_lab/software/Bracken-2.8/bracken -d $DBNAME -i ${output_folder}/${run}.k2report -r 150 -l S -t ${thread_number} -o ${output_folder}/${run}.bracken -w ${output_folder}/${run}.breport 

rm ${output_folder}/${run}.k2report
rm ${output_folder}/${run}.kraken2

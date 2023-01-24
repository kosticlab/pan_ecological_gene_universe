#!/bin/bash
set -e
source activate /home/sez10/miniconda3/envs/meta_assemblers

dirname=${1}
category=${2}
output_folder=${3}
adapters_reference=${4}
bitmask_file=${5}
sprism_file=${6}
temp_dir=${7}
thread_number=${8}
database=${9}
database_fastq=${10}
final_output_dir=${11}
mkdir -p ${output_folder}/${dirname}
export OMP_NUM_THREADS=${thread_number}

module load sratoolkit/2.10.7

prefetch --max-size 200G -O ${output_folder}/${dirname} $dirname
fasterq-dump -O ${output_folder}/${dirname} --threads ${thread_number} ${output_folder}/${dirname}/${dirname}.sra

rm ${output_folder}/${dirname}/${dirname}.sra
if [ -f "${output_folder}/${dirname}/${dirname}.sra.prf" ]; then
    rm ${output_folder}/${dirname}/${dirname}.sra.prf
fi
if [ -f "${output_folder}/${dirname}/${dirname}.sra.tmp" ]; then
    rm ${output_folder}/${dirname}/${dirname}.sra.tmp
fi

f1=${output_folder}/${dirname}/${dirname}.sra_1.fastq
f2=${output_folder}/${dirname}/${dirname}.sra_2.fastq

# remove adapters
bbduk.sh -Xmx8g in1=${f1} in2=${f2} out1=${output_folder}/${dirname}/${dirname}_1.trimmed.fastq out2=${output_folder}/${dirname}/${dirname}_2.trimmed.fastq ref=${adapters_reference} threads=${thread_number} qin=33 ktrim=r k=23 mink=11 hdist=1 tpe tbo

rm ${f1}
rm ${f2}

f1=${output_folder}/${dirname}/${dirname}_1.trimmed.fastq
f2=${output_folder}/${dirname}/${dirname}_2.trimmed.fastq

if [[ $category == "human" ]]
then
mkdir -p ${temp_dir}
bmtagger.sh -b ${bitmask_file} -x ${sprism_file} -T ${temp_dir} -q1 -1 ${f1} -2 ${f2} -o ${output_folder}/${dirname}/${dirname}_human_free -X
rm ${f1}
rm ${f2}
f1=${output_folder}/${dirname}/${dirname}_human_free_1.fastq
f2=${output_folder}/${dirname}/${dirname}_human_free_2.fastq
fi

cat ${f1} ${f2} > ${output_folder}/${dirname}/${dirname}.fastq

rm ${f1}
rm ${f2}
outputname=${output_folder}/${dirname}/${dirname}_output.gz
bam_filename=${output_folder}/${dirname}/${dirname}'.catalog.bam'

diamond blastx --db ${database} --query ${output_folder}/${dirname}/${dirname}.fastq --outfmt 101 -p ${thread_number} --compress 1 --unal 0 -o ${outputname} 
rm ${output_folder}/${dirname}/${dirname}.fastq
zcat ${outputname} | samtools view -T ${database_fastq} -@ ${num_threads} -b -h -o ${bam_filename} -
countsfile=${final_output_dir}/${dirname}_alignment_data.tsv
conda deactivate
source activate r_env
module load gcc/6.2.0 samtools/1.9
Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/scripts/count_genes.R ${bam_filename} ${countsfile} 
#rm ${outputname}

#sort bam file
#samtools 'sort' \
#    -l 9 \
#    -o ${bam_filename%.*}'.sorted.bam' \
#    -O bam \
#    -@ ${thread_number} \
#    ${bam_filename}

#rm ${bam_filename}
#bam_filename=${bam_filename%.*}'.sorted.bam'

# Index the bam
#bam_index_filename=${bam_filename%.*}'.bai'
#samtools 'index' -@ ${thread_number} -b ${bam_filename} ${bam_index_filename}

# extract reads
#countsfile=${output_folder}/${dirname}/${dirname}_alignment_data.tsv
#samtools idxstats -@ ${thread_number} ${bam_filename} > ${countsfile}
#rm ${bam_filename}
#rm ${bam_index_filename}
#gzip ${countsfile}

#mv ${countsfile}.gz ${final_output_dir}

#!/bin/bash

sample=${1}
runs=${2}
ecology=${3}
output_dir=${4}
thread_number=${5}
mkdir -p ${output_dir}/${ecology}/${sample}

module load sratoolkit/2.10.7

paired_end_one_ar=()
paired_end_two_ar=()
for i in ${runs//;/ }
do
    prefetch --max-size 200G -O ${output_dir}/${ecology}/${sample} ${i}
    fasterq-dump -O ${output_dir}/${ecology}/${sample} --threads ${thread_number} ${output_dir}/${ecology}/${sample}/${i}.sra
    paired_end_one_ar+=("${output_dir}/${ecology}/${sample}/${i}.sra_1.fastq")
    paired_end_two_ar+=("${output_dir}/${ecology}/${sample}/${i}.sra_2.fastq")
    rm ${output_dir}/${ecology}/${sample}/${i}.sra
done

# get length of each array
paired_end_one_str="${paired_end_one_ar[@]}"
paired_end_two_str="${paired_end_two_ar[@]}"

paired_end_one_ar_length=${#paired_end_one_ar[@]}
paired_end_two_ar_length=${#paired_end_two_ar[@]}

if [ "${paired_end_one_ar_length}" -gt "1" ]
then
   cat ${paired_end_one_str} > ${output_dir}/${ecology}/${sample}/${sample}_1.fastq
   rm ${paired_end_one_str}
else
   mv ${paired_end_one_str} ${output_dir}/${ecology}/${sample}/${sample}_1.fastq
fi

if [ "${paired_end_two_ar_length}" -gt "1" ]
then
   cat ${paired_end_two_str} > ${output_dir}/${ecology}/${sample}/${sample}_2.fastq
   rm ${paired_end_two_str}
else
   mv ${paired_end_two_str} ${output_dir}/${ecology}/${sample}/${sample}_2.fastq 
fi

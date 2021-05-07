#!/bin/bash

input_file=${1}
output_main_dir=${2}
echo ${input_file}
#for filename in $(find /n/scratch3/users/v/vnl3/orfleton_v2_prokka_output/n/ -name '*.faa')
#for filename in /n/scratch3/users/v/vnl3/orfleton_v2_prokka_output/n/scratch2/btt5/orfletonv2/prokka_02/PSM7J1CS_P_prokka_out/PROKKA_04202020.faa
while read filename;
do
    echo ${filename}_to_cluster
    sampleName=$(basename $(dirname ${filename}))
    output_dir=${output_main_dir}/${sampleName}
    mkdir -p ${output_dir}
    mkdir -p ${output_dir}/${sampleName}_tmp
    mmseqs createdb ${filename} ${output_dir}/${sampleName}_DB
    mmseqs cluster -c 0.9 --min-seq-id 0.30 ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB_clu ${output_dir}/${sampleName}_tmp
    mmseqs createtsv ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB_clu ${output_dir}/${sampleName}_DB_clu.tsv
    find ${output_dir} -type f -not -name '*.tsv' -delete
    rm -r ${output_dir}/${sampleName}_tmp
#    gene_number=$(cat ${output_dir}/${sampleName}_DB_clu.tsv | awk '{print $1}' | sort | uniq | wc -l)
#    echo ${sampleName} ${gene_number}
#    rm -r ${output_dir}
done < ${input_file}

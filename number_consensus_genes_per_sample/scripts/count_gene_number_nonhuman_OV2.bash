#!/bin/bash
source activate /home/sez10/miniconda3/envs/meta_assemblers

input_file=${1}
output_main_dir=${2}
prefix="gene_name_"
suffix=".txt"
while read filename
do
    sampleName_a=$(basename ${filename})
    echo ${sampleName_a}
    sampleName_b=${sampleName_a#"$prefix"}
    echo ${sampleName_b}
    sampleName=${sampleName_b%"$suffix"}
    echo ${sampleName}
    output_dir=${output_main_dir}/${sampleName}
    mkdir -p ${output_dir}
    mkdir -p ${output_dir}/${sampleName}_tmp
    seqtk subseq /n/scratch3/users/b/btt5/orfletonv2/pan_genes ${filename} > ${output_dir}/${sampleName}.fasta
    mmseqs createdb ${output_dir}/${sampleName}.fasta ${output_dir}/${sampleName}_DB
    mmseqs linclust -c 0.9 --min-seq-id 0.30 ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB_clu ${output_dir}/${sampleName}_tmp
    mmseqs createtsv ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB ${output_dir}/${sampleName}_DB_clu ${output_dir}/${sampleName}_DB_clu.tsv
    find ${output_dir} -type f -not -name '*.tsv' -delete
    rm -r ${output_dir}/${sampleName}_tmp
done < ${input_file}

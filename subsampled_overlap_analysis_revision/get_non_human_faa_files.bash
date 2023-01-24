#!/bin/bash
source activate /home/sez10/miniconda3/envs/meta_assemblers

input_file=${1}
output_dir=${2}
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
    seqtk subseq /n/scratch3/users/a/adk9/_RESTORE/adk9/orfv2/pangenes/pan_genes.gz ${filename} > ${output_dir}/${sampleName}.fasta
done < ${input_file}

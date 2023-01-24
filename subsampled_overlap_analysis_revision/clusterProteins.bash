#!/bin/bash

input=${1}
output_suffix=${2}
temp_folder=${3}
sequence_identity=${4}
output_dir=${5}
mkdir -p ${temp_folder}
mkdir -p ${output_dir}
mmseqs createdb ${input} ${output_dir}/all_seqs_db_${output_suffix}

mmseqs cluster -c 0.9 --min-seq-id ${sequence_identity} ${output_dir}/all_seqs_db_${output_suffix} ${output_dir}/all_seqs_db_${output_suffix}_clu ${temp_folder}

mmseqs createtsv ${output_dir}/all_seqs_db_${output_suffix} ${output_dir}/all_seqs_db_${output_suffix} ${output_dir}/all_seqs_db_${output_suffix}_clu ${output_dir}/all_seqs_db_${output_suffix}_clu.tsv

mmseqs createsubdb ${output_dir}/all_seqs_db_${output_suffix}_clu ${output_dir}/all_seqs_db_${output_suffix} ${output_dir}/all_seqs_db_${output_suffix}_clu_rep

mmseqs convert2fasta ${output_dir}/all_seqs_db_${output_suffix}_clu_rep ${output_dir}/all_seqs_db_${output_suffix}_clu_rep.fasta


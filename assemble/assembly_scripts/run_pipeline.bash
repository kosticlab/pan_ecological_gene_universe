#!/bin/bash
source activate /home/sez10/miniconda3/envs/meta_assemblers

dirname=${1}
filenames=${2}
output_folder=${3}
adapters_reference=${4}
bitmask_file=${5}
sprism_file=${6}
temp_dir=${7}
thread_number=${8}
mkdir -p ${output_folder}/${dirname}
pairedEnd=0

export OMP_NUM_THREADS=${thread_number}

#set -e

if [[ $filenames == *","* ]]
then
pairedEnd=1
f1="$( echo "$filenames" | cut -f1 -d',' )"
f2="$( echo "$filenames" | cut -f2 -d',' )"
else # only 1 fastq file
# check if it is an interleved file (1 file but paired end)
reformat.sh in=${filenames} vint
isPaired=$?
# if 0 then it is paired end
if [ "$isPaired" -eq "0" ]
then
pairedEnd=1
reformat.sh in=${filenames} out1=${output_folder}/${dirname}/${dirname}_1.raw.fastq out2=${output_folder}/${dirname}/${dirname}_2.raw.fq
f1=${output_folder}/${dirname}/${dirname}_1.raw.fastq
f2=${output_folder}/${dirname}/${dirname}_2.raw.fq
rm ${filenames}
fi
fi

if [ "$pairedEnd" -eq 1 ]
then
#f1="$( echo "$filenames" | cut -f1 -d',' )"
#f2="$( echo "$filenames" | cut -f2 -d',' )"
# first trim
bbduk.sh -Xmx8g in1=${f1} in2=${f2} out1=${output_folder}/${dirname}/${dirname}_1.trimmed.fastq out2=${output_folder}/${dirname}/${dirname}_2.trimmed.fastq ref=${adapters_reference} threads=${thread_number} qin=33 ktrim=r k=23 mink=11 hdist=1 tpe tbo
rm ${f1}
rm ${f2}
# remove contamination
bmtagger.sh -b ${bitmask_file} -x ${sprism_file} -T ${temp_dir} -q1 -1 ${output_folder}/${dirname}/${dirname}_1.trimmed.fastq -2 ${output_folder}/${dirname}/${dirname}_2.trimmed.fastq -o ${output_folder}/${dirname}/${dirname}_human_free -X
rm ${output_folder}/${dirname}/${dirname}_1.trimmed.fastq
rm ${output_folder}/${dirname}/${dirname}_2.trimmed.fastq
# now assemble using metaspades
mkdir -p ${output_folder}/${dirname}/${dirname}_ms_out
python /home/sez10/SPAdes-3.13.1-Linux/bin/metaspades.py --threads ${thread_number} --tmp-dir ${temp_dir} -m 150 -1 ${output_folder}/${dirname}/${dirname}_human_free_1.fastq -2 ${output_folder}/${dirname}/${dirname}_human_free_2.fastq -o ${output_folder}/${dirname}/${dirname}_ms_out
rm ${output_folder}/${dirname}/${dirname}_human_free_1.fastq
rm ${output_folder}/${dirname}/${dirname}_human_free_2.fastq
# delete everything but the contigs.fasta file which is what we actually want
find ${output_folder}/${dirname}/${dirname}_ms_out -not -name 'contigs.fasta' -delete
# run prokka
prokka --outdir ${output_folder}/${dirname}/${dirname}_prokka_out --force --addgenes --metagenome --cpus ${thread_number} --mincontiglen 1 ${output_folder}/${dirname}/${dirname}_ms_out/contigs.fasta
else
# trim
bbduk.sh -Xmx8g in=${filenames} out=${output_folder}/${dirname}/${dirname}.trimmed.fastq ref=${adapters_reference} threads=${thread_number} ktrim=r qin=33 k=23 mink=11 hdist=1 tpe tbo
rm ${filenames}
# remove human reads
bmtagger.sh -b ${bitmask_file} -x ${sprism_file} -T ${temp_dir} -q1 -1 ${output_folder}/${dirname}/${dirname}.trimmed.fastq -o ${output_folder}/${dirname}/${dirname}_human_free -X
rm ${output_folder}/${dirname}/${dirname}.trimmed.fastq
# then assemble with megahit
megahit --mem-flag 2 --num-cpu-threads ${thread_number} -r ${output_folder}/${dirname}/${dirname}_human_free.fastq -o ${output_folder}/${dirname}/${dirname}_mh_out
rm ${output_folder}/${dirname}/${dirname}_human_free.fastq
# run prokka to annotate
prokka --outdir ${output_folder}/${dirname}/${dirname}_prokka_out --force --addgenes --metagenome --cpus ${thread_number} --mincontiglen 1 ${output_folder}/${dirname}/${dirname}_mh_out/final.contigs.fa
fi


#!/bin/bash
set -e
source activate /home/sez10/miniconda3/envs/meta_assemblers

dirname=${1}
output_folder=${2}
temp_dir=${3}
thread_number=${4}
database_list=${5}
database_fastq_list=${6}
mkdir -p ${output_folder}/${dirname}
export OMP_NUM_THREADS=${thread_number}

module load sratoolkit/2.10.7
prefetch --max-size 52428800 --force no -O ${output_folder}/${dirname} $dirname
fastq-dump --split-files --outdir ${output_folder}/${dirname} ${output_folder}/${dirname}/${dirname}.sra

rm ${output_folder}/${dirname}/${dirname}.sra
if [ -f "${output_folder}/${dirname}/${dirname}.sra.prf" ]; then
    rm ${output_folder}/${dirname}/${dirname}.sra.prf
fi
if [ -f "${output_folder}/${dirname}/${dirname}.sra.tmp" ]; then
    rm ${output_folder}/${dirname}/${dirname}.sra.tmp
fi
# subsample fastq files so that I dont have to normalize downstream
seqtk sample -s100 ${output_folder}/${dirname}/${dirname}_1.fastq 2039003 > ${output_folder}/${dirname}/${dirname}_subsamp_1.fastq
seqtk sample -s100 ${output_folder}/${dirname}/${dirname}_2.fastq 2039003 > ${output_folder}/${dirname}/${dirname}_subsamp_2.fastq

f1=${output_folder}/${dirname}/${dirname}_subsamp_1.fastq
f2=${output_folder}/${dirname}/${dirname}_subsamp_2.fastq

rm ${output_folder}/${dirname}/${dirname}_1.fastq
rm ${output_folder}/${dirname}/${dirname}_2.fastq

cat ${output_folder}/${dirname}/${dirname}_subsamp_1.fastq ${output_folder}/${dirname}/${dirname}_subsamp_2.fastq > ${output_folder}/${dirname}/${dirname}_subsamp.fastq
rm ${output_folder}/${dirname}/${dirname}_subsamp_1.fastq
rm ${output_folder}/${dirname}/${dirname}_subsamp_2.fastq

## now align to ALP gene
IFS=',' read -ra database_array <<< "$database_list"
IFS=',' read -ra database_fastq_array <<< "$database_fastq_list"
for i in "${!database_array[@]}"; do
    database="${database_array[${i}]}"
    database_nopath=${database##*/}
    database_name=${database_nopath%.dmnd}
    database_fastq="${database_fastq_array[${i}]}"
    diamond_out=${output_folder}/${dirname}/${dirname}_${database_name}.alignment_out
    bam_out=${output_folder}/${dirname}/${dirname}_${database_name}.bam
    # check how many reads in fastq file
    echo $(cat ${output_folder}/${dirname}/${dirname}_subsamp.fastq|wc -l)/4|bc
    echo ${database}
    echo ${database_fastq}
    diamond blastx --db ${database} --query ${output_folder}/${dirname}/${dirname}_subsamp.fastq --outfmt 101 -p ${thread_number} -o ${diamond_out} --tmpdir ${temp_dir}

    echo "converting diamond output to BAM file"
    cat ${diamond_out} | samtools view -T ${database_fastq} -@ ${thread_number} -b -h -o ${bam_out} -
    # reheader bamfile. Add ID:DIAMOND tag to PG tag in header
    #bam_header=${output_folder}/${dirname}/${dirname}_${database_name}.bam.header.txt
    #bam_header_new=${output_folder}/${dirname}/${dirname}_${database_name}.bam.header.new.txt
    #bam_header_new2=${output_folder}/${dirname}/${dirname}_${database_name}.bam.header.new.2.txt
    #bam_with_new_header=${output_folder}/${dirname}/${dirname}_${database_name}.newheader.bam
    #bam_mapped_only=${output_folder}/${dirname}/${dirname}_${database_name}.no.unmapped.bam
    #samtools view -H ${bam_out} > ${bam_header}
    #perl -pe "s/^(@PG.*)(\tPN:DIAMOND)(\s|\$)/\$1\tID:DIAMOND\$2\t/" ${bam_header} > ${bam_header_new}
    #grep -v ^@mm ${bam_header_new} > ${bam_header_new2}
    #rm ${bam_header_new}
    #samtools reheader ${bam_header_new2} ${bam_out} > ${bam_with_new_header}
    # next remove unmapped reads
    #samtools view -bF 4 ${bam_with_new_header} > ${bam_mapped_only}
    #rm ${bam_out}
    #rm ${bam_with_new_header}
    #rm ${bam_header_new2}
    #rm ${bam_header}
    rm ${diamond_out}

    # sort bam file
    echo "sorting bam file"
    sorted_bam=${output_folder}/${dirname}/${dirname}_${database_name}.sorted.bam
    samtools sort -l 9 -o ${sorted_bam} -@ ${thread_number} -O bam ${bam_out}
    rm ${bam_out}
    # remove duplicates using Picard
    #no_dups_bam=${output_folder}/${dirname}/${dirname}_${database_name}.dedup.bam
    #marks_metrics=${output_folder}/${dirname}/${dirname}_${database_name}_marked_dup_metrics.txt
    #module load picard/2.8.0
    #java -jar $PICARD/picard-2.8.0.jar MarkDuplicates I=${sorted_bam} O=${no_dups_bam} M=${marks_metrics} REMOVE_DUPLICATES=true
#    rm ${sorted_bam}
    echo "indexing bam file"
    samtools index -@ ${thread_number} -b ${sorted_bam}

    # extract reads
    countsfile=${output_folder}/${dirname}/${dirname}_${database_name}_raw_counts.tsv
    echo "extracting reads"
    samtools idxstats -@ ${thread_number} ${sorted_bam} > ${countsfile}
    gzip ${countsfile}
#    rm ${no_dups_bam}
#    rm ${no_dups_bam}.bai
    rm ${sorted_bam}
    rm ${sorted_bam}.bai
done
rm ${output_folder}/${dirname}/${dirname}_subsamp.fastq

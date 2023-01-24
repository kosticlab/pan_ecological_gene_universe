#!/bin/bash

targz=${1}
thread_number=${2}
output_dir=${3}

query=$(tar -xvzf ${targz} --wildcards --no-anchored '*.faa')

nopath=$(basename ${targz})
sampleName=$(echo ${nopath%_prokka_out.tar.gz})

#nopath=$(basename $(dirname /n/scratch3/users/v/vnl3/_RESTORE/orfleton_v2_prokka_output/DavidLA_2015__LD-Run2-35_prokka_out.tar.gz))
#sampleName=$(echo ${nopath%.faa})

/n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/Diamond_2.0.6/diamond blastp --db /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_CAT_database/2021-01-07.nr.dmnd --query ${query} -p ${thread_number} -o ${output_dir}/"${sampleName}"_aligned --taxonmap /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy/2021-01-07.prot.accession2taxid.FULL.gz --taxonnodes /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy/nodes.dmp --taxonnames /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy/names.dmp --top 11 --matrix "BLOSUM62" --evalue 0.001

python /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/parse_diamond_output.py ${output_dir}/"${sampleName}"_aligned 10 /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy/nodes.dmp /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy/names.dmp /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_CAT_database/2021-01-07.nr.fastaid2LCAtaxid /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_CAT_database/2021-01-07.nr.taxids_with_multiple_offspring False ${output_dir}/"${sampleName}"_taxID_annotated.txt

source activate /home/sez10/miniconda3_2/envs/cat
CAT add_names --force -i ${output_dir}/"${sampleName}"_taxID_annotated.txt -o ${output_dir}/"${sampleName}"_tax_names_annotated.txt -t /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy --only_official

rm ${output_dir}/"${sampleName}"_aligned

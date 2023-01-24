#!/bin/bash

input_file=${1}
core_number=${2}
output_dir=${3}
gffFile=$(tar -xvzf ${input_file} --wildcards --no-anchored '*.gff')
sed -n '/##FASTA/q;p' ${gffFile} > ${gffFile%.gff}.only.gff
fnaFile=$(tar -xvzf ${input_file} --wildcards --no-anchored '*.fna')
#sed '1,/##FASTA/d' ${gffFile} > ${gffFile%.gff}.only.fna
faaFile=$(tar -xvzf ${input_file} --wildcards --no-anchored '*.faa')
rm ${gffFile}
echo "Get the new gene Names"
if [ -s ${gffFile%.gff}.only.gff ]; then
source activate /home/sez10/miniconda3_2/envs/r_env
Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/map_old_to_CAT_geneNames.R ${gffFile%.gff}.only.gff
conda deactivate
else
tblFile=$(tar -xvzf ${input_file} --wildcards --no-anchored '*.tbl')
python /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/map_old_to_CAT_geneNames_with_tbl.py ${tblFile}
fi

rm ${gffFile%.gff}.only.gff
echo "Start Running Python script to format faa files correctly"
python /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/edit_faa.py ${gffFile%.gff}.gene.mapping.txt ${faaFile} ${fnaFile}
echo "Finish running python script"
nopath=$(basename ${input_file})
sampleName=$(echo ${nopath%.tar.gz})
mkdir -p ${output_dir}/${sampleName}
echo ${output_dir}/${sampleName}
source activate /home/sez10/miniconda3_2/envs/cat
CAT contigs --force -c ${fnaFile} -d /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_CAT_database -t /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy -p ${faaFile} --nproc ${core_number} --I_know_what_Im_doing --top 11 --out_prefix ${output_dir}/${sampleName}/${sampleName}
rm ${fnaFile}
rm ${faaFile}
# add names to contigs
CAT add_names --force -i ${output_dir}/${sampleName}/${sampleName}.contig2classification.txt -o ${output_dir}/${sampleName}/${sampleName}.contig2classification_named.txt -t /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy --only_official
# add names to ORFs via the LCA method
CAT add_names --force -i ${output_dir}/${sampleName}/${sampleName}.ORF2LCA.txt -o ${output_dir}/${sampleName}/${sampleName}.ORF2LCA_named.txt -t /n/scratch3/users/s/sez10/_RESTORE/CAT_prepare_20210107/2021-01-07_taxonomy --only_official
conda deactivate
source activate /home/sez10/miniconda3_2/envs/r_env
Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/annotate_contigs_ORFs/annotate_ORFS.R ${output_dir}/${sampleName}/${sampleName}.contig2classification_named.txt ${output_dir}/${sampleName}/${sampleName}.ORF2LCA_named.txt
rm ${output_dir}/${sampleName}/${sampleName}.alignment.diamond
rm ${output_dir}/${sampleName}/${sampleName}.contig2classification.txt
rm ${output_dir}/${sampleName}/${sampleName}.ORF2LCA.txt

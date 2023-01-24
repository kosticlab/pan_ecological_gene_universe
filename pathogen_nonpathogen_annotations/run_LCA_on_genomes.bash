#!/bin/bash

input_fna=${1}
output_folder=${2}
thread_number=${3}

nopath=$(basename ${input_fna})
sample=$(echo ${nopath%_genomic.fna})
source activate /home/sez10/miniconda3/envs/meta_assemblers

prokka --outdir ${output_folder}/${sample}/${sample}_prokka_out --locustag ${sample} --prefix ${sample} --addgenes --cpus ${thread_number} --mincontiglen 1 ${input_fna} 
conda deactivate
# run diamond
/n/scratch3/users/a/adk9/_RESTORE/adk9/orfleton/diamond blastp --db /n/scratch3/users/a/adk9/_RESTORE/adk9/orfleton/nr.dmnd --query ${output_folder}/${sample}/${sample}_prokka_out/${sample}.faa -p ${thread_number} -o ${output_folder}/${sample}/${sample}_aligned -f 102 --taxonmap /n/scratch3/users/a/adk9/_RESTORE/adk9/orfleton/prot.accession2taxid.gz --taxonnodes /n/scratch3/users/a/adk9/_RESTORE/adk9/orfleton/nodes.dmp
# now convert taxa IDs to names
source activate r_env
Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/pathogen_nonpathogen_annotations/annotate_genome_genes.R ${output_folder}/${sample}/${sample}_aligned

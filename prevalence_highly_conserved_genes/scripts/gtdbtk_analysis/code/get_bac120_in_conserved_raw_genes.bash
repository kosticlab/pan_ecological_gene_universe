#!/bin/bash
hmm=${1}
outputdir=${2}
hmm_nosuf=$(echo "${hmm}" | cut -f1 -d".")
hmm_nopath=$(echo "${hmm_nosuf##*/}")
source activate /home/sez10/miniconda3_2/envs/interproscan
hmmsearch --noali --tblout ${outputdir}/${hmm_nopath}_prev.txt --domtblout ${outputdir}/${hmm_nopath}_domain.txt -E 0.001 --domE 0.001 --cpu 5 ${hmm} /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/GTDB_analysis/raw_global_conservative_genes.faa > ${outputdir}/${hmm_nopath}.stdout
#rm ${outputdir}/${hmm_nopath}.stdout

#!/bin/bash

source activate /home/sez10/miniconda3/envs/meta_assemblers

seqtk subseq /n/scratch3/users/b/btt5/orfletonv2/pan_genes /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/GTDB_analysis/presence_in_consensus_genes/consensus_global_conservative_genes.txt > /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/GTDB_analysis/presence_in_consensus_genes/consensus_global_conservative_genes.faa

#!/bin/bash

source activate /home/sez10/miniconda3/envs/meta_assemblers

in_fasta=${1}
db_name=${2}
diamond makedb --in ${in_fasta} -d ${db_name}

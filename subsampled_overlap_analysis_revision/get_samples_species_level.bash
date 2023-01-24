#!/bin/bash

num_samples_per_ecology=${1}
output_dir=${2}

source activate r_env

Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/scripts/get_samples_species_level.R ${num_samples_per_ecology} ${output_dir}

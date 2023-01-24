#!/bin/bash

input=${1}
metadata=${2}

source activate r_env

Rscript /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/scripts/calc_distance_matrixes.R ${input} ${metadata}

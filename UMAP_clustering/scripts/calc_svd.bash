#!/bin/bash

source activate r_env

input_file=${1}
min_prev=${2}

Rscript calc_svd_2.R ${input_file} ${min_prev}

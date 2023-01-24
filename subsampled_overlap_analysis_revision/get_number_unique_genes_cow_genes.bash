#!/bin/bash

source activate r_env

Rscript scripts/get_number_unique_genes_cow_genes.R ${1} ${2}

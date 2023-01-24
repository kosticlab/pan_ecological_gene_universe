#!/bin/bash

zcat /n/scratch3/users/a/adk9/_RESTORE/adk9/orfv2/pangenes/pan_genes.gz | grep ">" | grep -f last_2_glacier_prokka_IDs.txt -F > last_2_glacier_gene_names.txt
cut -f 1 -d ' ' last_2_glacier_gene_names.txt | cut -c2- > last_2_glacier_gene_names_no_carrot.txt

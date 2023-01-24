#!/bin/bash

module load blast/2.12.0+
module load gcc/6.2.0

DBNAME=${1}
thread_number=${2}

#/home/sez10/kostic_lab/software/kraken2_scripts/kraken2-build --standard --threads ${thread_number} --db $DBNAME 
/home/sez10/kostic_lab/software/kraken2_2.1.2_scripts/kraken2-build --standard --threads ${thread_number} --db $DBNAME

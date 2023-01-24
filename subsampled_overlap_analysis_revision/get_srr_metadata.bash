#!/bin/bash

input=${1}
output=${2}

esearch -db sra -query ${input} | efetch -format runinfo > ${output}

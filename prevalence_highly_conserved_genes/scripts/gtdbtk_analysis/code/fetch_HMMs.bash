#!/bin/bash
source activate /home/sez10/miniconda3_2/envs/interproscan
domain=${1}
HMM=${2}

full_HMM=$(grep "${domain}." ${HMM} | awk '{print $2}')
hmmfetch ${HMM} ${full_HMM} > HMM_profiles/${full_HMM}.hmm

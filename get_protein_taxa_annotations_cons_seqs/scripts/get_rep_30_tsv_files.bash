#!/bin/bash

grep -f ${1} -F -w /n/scratch3/users/b/btt5/orfletonv2/tsv_data/pan_tsv_data > ${1}_tsv_data

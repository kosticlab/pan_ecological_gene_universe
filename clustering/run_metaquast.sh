#!/bin/bash

while read fnafile*; do

echo $fnafile
quast-5.0.2/metaquast.py --max-ref-number 0 -t 15 --fast -m 0 -o metaquast/${fnafile}__metaquast $fnafile

done<$1

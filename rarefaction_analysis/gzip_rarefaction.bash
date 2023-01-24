#!/bin/bash

folder=${1}

#gzip fastq_outputs/*/*/${folder}/*.fastq

for x in fastq_outputs/*/*/${folder}/*.fastq; do echo ${x}; gzip $x; done

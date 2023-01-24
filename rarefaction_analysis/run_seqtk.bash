#!/bin/bash
#SBATCH -N 1 
#SBATCH -t 0-02:00
#SBATCH -p short
#SBATCH --mem=40G

source activate /home/sez10/miniconda3/envs/meta_assemblers
line=${1}
mydir=$(dirname ${line})
if [[ $line == *".fastq.gz" ]]
then
prefix=${line%.fastq.gz}
elif [[ $line == *".fastq" ]]
then
prefix=${line%.fastq}
fi
# remove path
prefix2=${prefix##*/}
for size in 1K 10K 100K 500K 1M 5M 10M 20M 30M 40M
do
myout_folder=${mydir}/${size}
mkdir -p ${myout_folder}
if [ "$size" == "1K" ]
then
seqtk sample -s100 $line 1000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "10K" ]
then
seqtk sample -s100 $line 10000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "100K" ]
then
seqtk sample -s100 $line 100000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "500K" ]
then
seqtk sample -s100 $line 500000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "1M" ]
then
seqtk sample -s100 $line 1000000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "5M" ]
then
seqtk sample -s100 $line 5000000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "10M" ]
then
seqtk sample -s100 $line 10000000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "20M" ]
then
seqtk sample -s100 $line 20000000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "30M" ]
then
seqtk sample -s100 $line 30000000 > ${myout_folder}/${prefix2}.fastq
elif [ "$size" == "40M" ]
then
seqtk sample -s100 $line 40000000 > ${myout_folder}/${prefix2}.fastq
fi
done

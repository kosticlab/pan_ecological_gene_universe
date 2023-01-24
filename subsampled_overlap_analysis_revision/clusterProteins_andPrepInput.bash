#!/bin/bash

csv_file=${1}
csv_file_baseName=$(basename ${csv_file})

faa_array=()
pathNames=$(tail -n +2 ${csv_file} | awk -F ',' '{print $7}')
for x in $pathNames
do
tar_file_no_quotes="${x%\"}"
tar_file_no_quotes="${tar_file_no_quotes#\"}"
if [[ "$tar_file_no_quotes" == *".tar.gz" ]]
then
    faa_file=$(tar -xvzf ${tar_file_no_quotes} --wildcards --no-anchored '*.faa')
    faa_array+=(${faa_file})
else
    faa_array+=(${tar_file_no_quotes})
fi
done

faa_string="${faa_array[@]}"

cat ${faa_string} > ${csv_file_baseName%.csv}.faa

mkdir -p ${csv_file_baseName%.csv}_temp
mkdir -p ${csv_file_baseName%.csv}_clustered

/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/scripts/clusterProteins.bash ${csv_file_baseName%.csv}.faa ${csv_file_baseName%.csv} ${csv_file_baseName%.csv}_temp 0.30 ${csv_file_baseName%.csv}_clustered 
rm -r ${csv_file_baseName%.csv}_temp
rm ${csv_file_baseName%.csv}.faa

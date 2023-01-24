#!/bin/bash

while read line
do
echo $(cat ${line}|wc -l)/4|bc
done < ${1} > ${2} 

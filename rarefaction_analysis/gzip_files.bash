#!/bin/bash

while read line
do
echo ${line}
gzip ${line}
done < ${1}

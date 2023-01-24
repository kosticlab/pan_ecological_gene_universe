import sys
import re
tbl_file = sys.argv[1]

f = open(tbl_file,'r')
outFile = re.sub(".tbl", ".gene.mapping.txt", tbl_file)
print(outFile)
w = open(outFile,'w')

contig_name = ''
feature_type = ''
for line in f:
    split_line = line.split()
    if line[0] == ">":
        contig_name = split_line[1]
        contig_name = re.sub("_", "-", contig_name)
    elif len(split_line) > 2:
        feature_type = split_line[2]
    elif split_line[0] == "locus_tag" and feature_type =="gene":
            geneName = split_line[1]
            geneNumber = geneName.split("_")[1]
            newGeneName = contig_name+"_"+geneNumber
            w.write(geneName+"\t"+newGeneName+"\n")

f.close()
w.close()

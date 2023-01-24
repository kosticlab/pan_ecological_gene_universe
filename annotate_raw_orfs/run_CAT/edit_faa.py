from BCBio import GFF
from Bio import SeqIO
import sys

geneMapping_file = sys.argv[1]
faa_file = sys.argv[2]
fna_file = sys.argv[3]

print(geneMapping_file)
print(faa_file)
print(fna_file)

print("Start script")

gene_dict = {}

f = open(geneMapping_file,'r')
for line in f:
    line_split = line.split("\t")
    gene_ID = line_split[0]
    newGeneName = line_split[1]
    gene_dict[gene_ID] = newGeneName

f.close()

#print("Get correct names")
#for rec in GFF.parse(in_handle,limit_info=limit_info):
#    print(rec)
#    contig = rec.id
#    # replace underscores with hyphens
#    contig = contig.replace("_","-")
#    for features in rec.features:
#        gene_ID = features.id
#        gene_number = gene_ID.split("_")[1]
#        print(gene_ID)
#        #print(features.description)
#        #newGeneName = "contig"+"_"+gene_ID
#        #record_dict[gene_ID].id = newGeneName
#        gene_dict[gene_ID] = contig+"_"+gene_number
#    #with open(faa_file,'w') as handle:
#    #    SeqIO.write(record_dict.values(), handle, 'fasta')

#in_handle.close()

newName_seq = []
print("Change names in faa file")
with open(faa_file) as handle:
    for record in SeqIO.parse(handle, "fasta"):
        #print(record.id)
        #print(record.description)
        record.id = gene_dict[record.id] 
        record.description = ""
        newName_seq.append(record)

SeqIO.write(newName_seq, faa_file, "fasta")

print("Change names in fna file")
newfna = []
with open(fna_file) as handle:
    for record in SeqIO.parse(handle, "fasta"):
        record.id = record.id.replace("_","-")
        record.description = ""
        newfna.append(record)

SeqIO.write(newfna, fna_file, "fasta")

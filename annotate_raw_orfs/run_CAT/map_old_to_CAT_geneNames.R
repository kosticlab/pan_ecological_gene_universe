args = commandArgs(trailingOnly=TRUE)

gff_file=args[1]

library(rtracklayer)

gff_data = readGFF(gff_file)
# get CDS lines only
gff_data = gff_data[gff_data$type == "CDS",]
contigs = gsub("_","-",gff_data$seqid)
gene_number = sapply(strsplit(gff_data$ID,split="_"), function(x) x[2])
newGeneName = paste(contigs,gene_number,sep="_")
orig_to_new_geneName = data.frame(gff_data$ID,newGeneName)
write.table(orig_to_new_geneName,file=gsub(".only.gff",".gene.mapping.txt",gff_file),row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

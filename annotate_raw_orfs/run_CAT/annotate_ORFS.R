args = commandArgs(trailingOnly=TRUE)

contig_annotations=args[1]
orf_annotations=args[2]

library(data.table)

contig_df = fread(contig_annotations,header=TRUE,sep="\t",data.table=FALSE,fill=TRUE)
orf_df = fread(orf_annotations,header=TRUE,sep="\t",data.table=FALSE,fill=TRUE)
colnames(orf_df)[5:11] = paste("LCA",colnames(orf_df)[5:11],sep="_")
# get contig name in orf name only
contig_name = sapply(strsplit(orf_df[,1],split="_"), function(x) x[1])
contig_df_ordered = contig_df[match(contig_name,contig_df[,1]),]
colnames(contig_df_ordered)[c(6,7,8,9,10,11,12)] = paste("CAT",colnames(contig_df_ordered)[c(6,7,8,9,10,11,12)],sep="_")

orf_df = cbind(orf_df,contig_df_ordered[,c(6,7,8,9,10,11,12)])
write.csv(orf_df,file=gsub(".txt","_CAT.txt",orf_annotations),row.names=FALSE)

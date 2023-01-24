args = commandArgs(trailingOnly=TRUE)

bamFile = args[1] # iteration10_clustered/all_seqs_db_iteration10_clu.tsv
output_file = args[2]
library(data.table)
counts = fread(cmd=paste("samtools view", bamFile,"| awk '{print $3}'"),header=FALSE)
setkey(counts,V1)
mycounts = counts[,.N,by=V1]
colnames(mycounts) = c("representative_gene","counts")
write.csv(mycounts,file=output_file)
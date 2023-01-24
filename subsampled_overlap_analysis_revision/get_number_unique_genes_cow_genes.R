args = commandArgs(trailingOnly=TRUE)
tsv_file = args[1] # iteration10_clustered/all_seqs_db_iteration10_clu.tsv
metadata = args[2] # /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/human_env_metadata_may_7_2021.csv

library(data.table)
library(ggplot2)

metadata_df = read.csv(metadata)

mydf = fread(tsv_file,header=FALSE,sep="\t",data.table=FALSE)
colnames(mydf) = c("representative","cluster_member")
mydf$cluster_member_sample = sapply(strsplit(mydf$cluster_member,split="_"), function(x) x[length(x)-1])
mydf$ecology = metadata_df[match(mydf$cluster_member_sample,metadata_df$prokka_id),"ecology"]
# get unique rows only. since we want it to be binary. remove the cluster member. we just want to know whether the sample has at least one representative in the cluster
mydf_rep_ecology = unique(mydf[,-c(2,3)])
mydf_rep_ecology$freq = 1
mydf_rep_ecology_wide = reshape2::dcast(mydf_rep_ecology, ecology ~ representative,value.var="freq")
rownames(mydf_rep_ecology_wide) = mydf_rep_ecology_wide[,1]
mydf_rep_ecology_wide = mydf_rep_ecology_wide[,-1]
mydf_rep_ecology_wide = as.matrix(mydf_rep_ecology_wide)
mydf_rep_ecology_wide[is.na(mydf_rep_ecology_wide)] = 0
  
# first get genes only in a single ecology.
mydf_rep_ecology_wide_singletons = mydf_rep_ecology_wide[,colSums(mydf_rep_ecology_wide) == 1]
# now for each gene get the ecology its in
row_indexes_gene_present_in = apply(mydf_rep_ecology_wide_singletons,2, function(x) which(x==1))
ecologies_of_singleton_genes = rownames(mydf_rep_ecology_wide_singletons)[row_indexes_gene_present_in]
  
singleton_gene_ecology_df = data.frame(gene=colnames(mydf_rep_ecology_wide_singletons),ecology=ecologies_of_singleton_genes)
# now get number of unique genes per ecology
singleton_gene_ecology_dt = as.data.table(singleton_gene_ecology_df)
num_singletons_per_ecology = singleton_gene_ecology_dt[,.N,by=ecology]
num_singletons_per_ecology = num_singletons_per_ecology[order(ecology)]
#num_singletons_per_ecology_vec = as.numeric(num_singletons_per_ecology$N)
#names(num_singletons_per_ecology_vec) = num_singletons_per_ecology$ecology
# also specifically get the genes that are in cow gut only
cowGenes = singleton_gene_ecology_dt[ecology=="cow"]$gene

write.table(num_singletons_per_ecology,file=gsub(".tsv","_num_singletons_per_ecology.tsv",tsv_file),sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)
write.table(cowGenes,file=gsub(".tsv","_cowgenes.txt",tsv_file),col.names=FALSE,row.names=FALSE,quote=FALSE)

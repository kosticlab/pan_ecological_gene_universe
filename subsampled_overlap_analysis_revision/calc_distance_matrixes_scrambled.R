args = commandArgs(trailingOnly=TRUE)

tsv_file = args[1] # iteration10_clustered/all_seqs_db_iteration10_clu.tsv
metadata = args[2] # /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/human_env_metadata_may_7_2021.csv
library(data.table)
library(vegan)
library(ggplot2)
mydf = fread(tsv_file,header=FALSE,sep="\t",data.table=FALSE)
metadata_df = read.csv(metadata)
colnames(mydf) = c("representative","cluster_member")
mydf$cluster_member_sample = sapply(strsplit(mydf$cluster_member,split="_"), function(x) x[length(x)-1])
mydf$ecology = metadata_df[match(mydf$cluster_member_sample,metadata_df$prokka_id),"ecology"]
# scramble ecology and representative genes
#mydf$cluster_member_sample = sample(mydf$cluster_member_sample)
#mydf$representative = sample(mydf$representative)
# get unique rows only. since we want it to be binary. remove the cluster member. we just want to know whether the sample has at least one representative in the cluster
#mydf_rep_samp = unique(mydf[,-c(2,4)])
#mydf_rep_samp$freq = 1
#mydf_rep_samp_wide = reshape2::dcast(mydf_rep_samp, cluster_member_sample ~ representative,value.var="freq")
#rownames(mydf_rep_samp_wide) = mydf_rep_samp_wide[,1]
#mydf_rep_samp_wide = mydf_rep_samp_wide[,-1]
#mydf_rep_samp_wide = as.matrix(mydf_rep_samp_wide)
#mydf_rep_samp_wide[is.na(mydf_rep_samp_wide)] = 0
#dist_mat = vegdist(mydf_rep_samp_wide,method="jaccard")
#dist_mat = as.matrix(dist_mat)
#write.csv(dist_mat,file=gsub(".tsv","sample_jaccard_mat.tsv",tsv_file))

#dist_mat_wide <- reshape2::melt(as.matrix(dist_mat), varnames = c("row", "col"))
# remove duplicate rows
#dist_mat_wide = dist_mat_wide[as.numeric(dist_mat_wide$row) > as.numeric(dist_mat_wide$col), ]
#dist_mat_wide$ecology_row = metadata_df[match(dist_mat_wide$row,metadata_df$prokka_id),"ecology"]
#dist_mat_wide$ecology_col = metadata_df[match(dist_mat_wide$col,metadata_df$prokka_id),"ecology"]
#dist_mat_wide$same_or_diff = dist_mat_wide$ecology_row == dist_mat_wide$ecology_col
#dist_mat_wide$same_or_diff[dist_mat_wide$same_or_diff == FALSE] = "different"
#dist_mat_wide$same_or_diff[dist_mat_wide$same_or_diff == TRUE] = "same"

#dist_mat_wide_same_type_beta = dist_mat_wide[dist_mat_wide$same_or_diff == "same",]

#ggplot(dist_mat_wide_same_type_beta,aes(x=ecology_row,y=value)) + geom_boxplot(outlier.shape = NA) + geom_jitter()

# also calculate alpha diversity
#alpha_div = rowSums(mydf_rep_samp_wide)
#metadata_df[match(names(alpha_div),metadata_df$prokka_id),"ecology"]
#alpha_div_df = data.frame(number_of_genes = alpha_div,ecology=metadata_df[match(names(alpha_div),metadata_df$prokka_id),"ecology"])

## now get distance matrix based on ecology 

mydf$representative = sample(mydf$representative)
mydf$ecology = sample(mydf$ecology)

mydf_rep_ecology = unique(mydf[,-c(2,3)])
mydf_rep_ecology$freq = 1
mydf_rep_ecology_wide = reshape2::dcast(mydf_rep_ecology, ecology ~ representative,value.var="freq")
rownames(mydf_rep_ecology_wide) = mydf_rep_ecology_wide[,1]
mydf_rep_ecology_wide = mydf_rep_ecology_wide[,-1]
mydf_rep_ecology_wide = as.matrix(mydf_rep_ecology_wide)
mydf_rep_ecology_wide[is.na(mydf_rep_ecology_wide)] = 0
dist_mat_rep_eco = vegdist(mydf_rep_ecology_wide,method="jaccard")
dist_mat_rep_eco = as.matrix(dist_mat_rep_eco)
write.csv(dist_mat_rep_eco,file=gsub(".tsv","ecology_jaccard_mat_scrambled.csv",tsv_file))

# also get the number of unique genes per ecology

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
write.table(num_singletons_per_ecology,file=gsub(".tsv","_num_singletons_per_ecology_scrambled.tsv",tsv_file),sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)



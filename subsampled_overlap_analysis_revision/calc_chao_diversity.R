args = commandArgs(trailingOnly=TRUE)

tsv_file = args[1] # iteration10_clustered/all_seqs_db_iteration10_clu.tsv
metadata = args[2] # /n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/human_env_metadata_may_7_2021.csv
library(data.table)
library(vegan)
library(ggplot2)
library(fossil)
mydf = fread(tsv_file,header=FALSE,sep="\t",data.table=FALSE)
metadata_df = read.csv(metadata)
colnames(mydf) = c("representative","cluster_member")
mydf$cluster_member_sample = sapply(strsplit(mydf$cluster_member,split="_"), function(x) x[length(x)-1])
mydf$ecology = metadata_df[match(mydf$cluster_member_sample,metadata_df$prokka_id),"ecology"]
# get unique rows only. since we want it to be binary. remove the cluster member. we just want to know whether the sample has at least one representative in the cluster
mydf_rep_samp = unique(mydf[,-c(2,4)])
mydf_rep_samp$freq = 1
mydf_rep_samp_wide = reshape2::dcast(mydf_rep_samp, cluster_member_sample ~ representative,value.var="freq")
rownames(mydf_rep_samp_wide) = mydf_rep_samp_wide[,1]
mydf_rep_samp_wide = mydf_rep_samp_wide[,-1]
mydf_rep_samp_wide = as.matrix(mydf_rep_samp_wide)
mydf_rep_samp_wide[is.na(mydf_rep_samp_wide)] = 0
chao_alpha_diversity = apply(mydf_rep_samp_wide,1, function(x) chao2(x))
sample_ecologies = metadata_df[match(names(chao_alpha_diversity), metadata_df$prokka_id),"ecology"]
dist_mat = data.frame(sample=names(chao_alpha_diversity),ecology=sample_ecologies,chao=chao_alpha_diversity)
write.csv(dist_mat,file=gsub(".tsv","sample_chao_mat.tsv",tsv_file),sep="\t",col.names=TRUE)

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

mydf_rep_ecology = unique(mydf[,-c(2,3)])
mydf_rep_ecology$freq = 1
mydf_rep_ecology_wide = reshape2::dcast(mydf_rep_ecology, ecology ~ representative,value.var="freq")
rownames(mydf_rep_ecology_wide) = mydf_rep_ecology_wide[,1]
mydf_rep_ecology_wide = mydf_rep_ecology_wide[,-1]
mydf_rep_ecology_wide = as.matrix(mydf_rep_ecology_wide)
mydf_rep_ecology_wide[is.na(mydf_rep_ecology_wide)] = 0
chao_alpha_diversity_ecology_wide = apply(mydf_rep_ecology_wide,1, function(x) chao2(x))
dist_mat = data.frame(ecology=names(chao_alpha_diversity_ecology_wide),chao=chao_alpha_diversity_ecology_wide)

write.csv(dist_mat,file=gsub(".tsv","ecology_chao_mat.tsv",tsv_file),sep="\t",col.names=TRUE)


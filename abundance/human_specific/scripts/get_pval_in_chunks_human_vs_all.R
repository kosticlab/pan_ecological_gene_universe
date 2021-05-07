#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

input_path=args[1] # always "/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/gene_abundances/gene_abundance_output"
database=args[2]
prevalent_samples_types = args[3]
gene_mapping = args[4]
output_folder = args[5]
split_number=as.character(args[6])
counter=as.character(args[7])
samples_of_interest = strsplit(prevalent_samples_types,",")[[1]]


library(ggplot2)
library(plyr)
library(dplyr)
library(tidyr)
library(reshape2)
library(cowplot)
library(data.table)
library(ggpubr)
library(rstatix)

all_count_files = list.files(path=input_path,pattern=paste("_",database,"_db_raw_counts.tsv.gz",sep=""),recursive = T,full.names = T)
split_dirs = strsplit(all_count_files,split="/")
sample_type = sapply(split_dirs,function(x) x[11])
sample_type = gsub("_samples_output","",sample_type)
sample_name = sapply(split_dirs,function(x) x[12])
database_name = basename(all_count_files)
database_name = sapply(strsplit(database_name,split="_"), function(x) paste(x[-1],collapse="_"))
database_name = gsub("all_seqs_rep_30_collapsed_cluster.fasta_","",database_name)
database_name = gsub("_db_raw_counts.tsv.gz","",database_name)

## now create a category column.
category = rep(NA,length(sample_type))
category[sample_type=="airways"] = "human_non_gut"
category[sample_type=="aquatic"] = "aquatic"
category[sample_type=="aquatic_sediment"] = "aquatic"
category[sample_type=="chicken_ceceum"] = "non_human_gut"
category[sample_type=="coral"] = "aquatic_host"
category[sample_type=="cow"] = "non_human_gut"
category[sample_type=="glacier_permafrost"] = "soil"
category[sample_type=="human_gut_nonindustry"] = "human_gut"
category[sample_type=="human_gut"] = "human_gut"
category[sample_type=="human_oral"] = "human_non_gut"
category[sample_type=="mice"] = "non_human_gut"
category[sample_type=="moose"] = "non_human_gut"
category[sample_type=="nasal"] = "human_non_gut"
category[sample_type=="phylloplane"] = "non_animal_host"
category[sample_type=="rhizosphere"] = "non_animal_host"
category[sample_type=="skin"] = "human_non_gut"
category[sample_type=="soil"] = "soil"
category[sample_type=="vaginal"] = "human_non_gut"

file_df = data.frame(filename=all_count_files,database=database_name,sample_type,sample_name,category)
## I only want a total of 25 human gut samples. 13 industrialized and 12 non-industrialized
industrialized_sample_names = unique(file_df[file_df$sample_type == "human_gut","sample_name"])
unindustrialized_sample_names = unique(file_df[file_df$sample_type == "human_gut_nonindustry","sample_name"])
all_human_gut_samples = c(industrialized_sample_names,unindustrialized_sample_names)
### pick a random 13 and 12 industrialized and non-industrialized respectivelys
set.seed(1)
chosen_industrialized = sample(industrialized_sample_names,13,replace = FALSE)
chosen_nonindustrialized = sample(unindustrialized_sample_names,12,replace = FALSE)
chosen_human_gut = c(chosen_industrialized,chosen_nonindustrialized)
not_chosen_human_gut = setdiff(all_human_gut_samples,chosen_human_gut)
## remove the human gut samples I did not choose
file_df = file_df[which(!file_df$sample_name%in%not_chosen_human_gut),]
## change the sample type from human_gut_nonindustry to just human_gut
file_df$sample_type[file_df$sample_type == "human_gut_nonindustry"] = "human_gut"

file_df$sample_type[file_df$sample_type == "phylloplane"] = "phyllosphere"
file_df = file_df[-which(file_df$sample_type == "rhizosphere"),]

sample_categories = unique(file_df[,c(3,5)])

get_abundance_per_ecosystem_no_outliers_v2 = function(database,mydf,sample_cat_db,samples_of_interest,gene_mapping,output_folder,counter,split_number) {
  samples_not_interest = sample_cat_db$sample_type[!sample_cat_db$sample_type%in%samples_of_interest]
  myTab1 = fread(cmd= paste('zcat',mydf[1,1],'| head -n',counter,'| tail -n',split_number),sep="\t",header=F)
  congenes_raw_mat = apply(mydf, 1, function(myrow) {
  myTab2 = fread(cmd= paste('zcat',myrow[1],'| head -n',counter,'| tail -n',split_number,'| cut -f3'),sep="\t",header=F)
  return(myTab2)
})
congenes_raw_mat = do.call("cbind",congenes_raw_mat)
congenes_raw_mat = as.matrix(congenes_raw_mat)
rownames(congenes_raw_mat) = myTab1$V1
#congenes_raw_mat = congenes_raw_mat[-match("*",rownames(congenes_raw_mat)),]
sample_type_vec = mydf[,3]
sample_group_vec = mydf[,5]
database_vec = mydf[,2]
samle_id = mydf[,4]
colnames(congenes_raw_mat) = sample_type_vec

#case_control_vec = sample_type_vec%in%samples_of_interest

### now load in the samples types they were prevalent in
gene_prev_mapping = fread(gene_mapping,header=F,sep="\t",data.table=F)
gene_prev_mapping = gene_prev_mapping[gene_prev_mapping$V1%in%rownames(congenes_raw_mat),]

gene_prev_mapping$V2 = gsub("AIRWAYS__","airways__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("AQUATIC__","aquatic__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("AQUATIC-SEDIMENT__","aquatic_sediment__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("CHICKEN__","chicken_ceceum__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("CORAL-REEF__","coral__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("COW__","cow__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("GLACIER-OR-PERMAFROST__","glacier_permafrost__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("GUT__","human_gut__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("MOOSE__","moose__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("NASAL__","nasal__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("ORAL__","human_oral__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("PLANTS__","phyllosphere__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("TERRESTRIAL-SOIL__","soil__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("VAGINAL__","vaginal__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("MOUSE__","mice__",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("SKIN__","skin__",gene_prev_mapping$V2)

gene_prev_mapping$V2 = gsub("__AIRWAYS$","__airways",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__AQUATIC$","__aquatic",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__AQUATIC-SEDIMENT$","__aquatic_sediment",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__CHICKEN$","__chicken_ceceum",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__CORAL-REEF$","__coral",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__COW$","__cow",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__GLACIER-OR-PERMAFROST$","__glacier_permafrost",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__GUT$","__human_gut",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__MOOSE$","__moose",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__NASAL$","__nasal",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__ORAL$","__human_oral",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__PLANTS$","__phyllosphere",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__TERRESTRIAL-SOIL$","__soil",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__VAGINAL$","__vaginal",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__MOUSE$","__mice",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("__SKIN$","__skin",gene_prev_mapping$V2)


gene_prev_mapping$V2 = gsub("^AIRWAYS$","airways",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^AQUATIC$","aquatic",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^AQUATIC-SEDIMENT$","aquatic_sediment",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^CHICKEN$","chicken_ceceum",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^CORAL-REEF$","coral",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^COW$","cow",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^GLACIER-OR-PERMAFROST$","glacier_permafrost",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^GUT$","human_gut",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^MOOSE$","moose",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^NASAL$","nasal",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^ORAL$","human_oral",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^PLANTS$","phyllosphere",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^TERRESTRIAL-SOIL$","soil",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^VAGINAL$","vaginal",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^MOUSE$","mice",gene_prev_mapping$V2)
gene_prev_mapping$V2 = gsub("^SKIN$","skin",gene_prev_mapping$V2)

### I only want genes that are in 2 or more ecologies
gene_prev_mapping_split = strsplit(gene_prev_mapping$V2,split="__")
multi_ecology_genes = gene_prev_mapping[sapply(gene_prev_mapping_split,length)>1,1]
congenes_raw_mat_gene_filt = congenes_raw_mat[multi_ecology_genes,]

start_line = as.numeric(counter)-as.numeric(split_number)
end_line = as.numeric(counter)
start_to_end = paste(start_line,end_line,sep="to")

pairwise_comparisions = expand.grid(samples_of_interest,samples_not_interest)
pairwise_comparisions = apply(pairwise_comparisions,2, as.character)

sig_gene_list = apply(pairwise_comparisions,1, function(samples_to_compare) {
	samples_to_compare_collapsed = paste(samples_to_compare,collapse="_vs_")
	cols_to_subset = colnames(congenes_raw_mat_gene_filt)%in%samples_to_compare
	congenes_raw_mat_sample_subset = congenes_raw_mat_gene_filt[,cols_to_subset]
	case_control_cols = colnames(congenes_raw_mat_sample_subset)%in%samples_to_compare[1]	
	pval_temp_list = apply(congenes_raw_mat_sample_subset,1, function(x) {
		case_temp = x[case_control_cols]
		control_temp = x[!case_control_cols]
		case_mean = mean(case_temp)
		control_mean = mean(control_temp)
		pvals_temp = wilcox.test(x=case_temp,y=control_temp,alternative="greater")$p.value
		return(c(pval=pvals_temp,prevalent_mean=case_mean,non_prevalent_mean=control_mean))
	})
	pval_df = t(pval_temp_list)
	pval_df = as.data.frame(pval_df)
	colnames(pval_df) = paste(colnames(pval_df),samples_to_compare_collapsed,sep="_")
	return(pval_df)
})
sig_gene_list_DF = do.call("cbind",sig_gene_list)
sig_gene_list_DF = cbind(geneName=rownames(sig_gene_list_DF),sig_gene_list_DF)
write.table(sig_gene_list_DF,file=paste(output_folder,"/",database,":",start_to_end,'.txt',sep=""),quote=F,sep="\t",col.names=T,row.names=F)
}

pvalList = get_abundance_per_ecosystem_no_outliers_v2(database=database,mydf=file_df,sample_cat_db=sample_categories,samples_of_interest=samples_of_interest,gene_mapping=gene_mapping,output_folder=output_folder,counter=counter,split_number=split_number)

library(parallel)
library(data.table)
setwd("/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/arch_plots_v2")
filesA = list.files("/n/scratch3/users/l/ldp9/_RESTORE/orfletonV2_orf_annotation/CAT_output/",pattern=".ORF2LCA_named.txt",recursive = TRUE,full.names = TRUE)
filesB = list.files("/n/scratch3/users/l/ldp9/_RESTORE/orfletonV2_orf_annotation/diamond_output/",pattern="_tax_names_annotated.txt",full.names = TRUE)
all_annotation_files = c(filesA,filesB)

gene_mappings_files = list.files("/n/scratch3/users/l/ldp9/_RESTORE/orfletonV2_orf_annotation/n",pattern=".gene.mapping.txt",recursive = TRUE,full.names = TRUE)
gene_mapping_sampleNames = sapply(strsplit(gene_mappings_files,split="/"), function(x) x[length(x)-1])
gene_mapping_sampleNames = gsub("_prokka_out","",gene_mapping_sampleNames)
gene_mapping_files_df = data.frame(gene_mapping_sampleNames,gene_mappings_files)


sample_metadata = read.csv("/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/human_env_metadata_may_7_2021.csv")

consensus_to_raw_geneList = fread("human_non_gut_consensus_genes.tsv",header=FALSE,sep="\t")
raw_gene_list = unique(consensus_to_raw_geneList$V1)
split_raw_genes = strsplit(raw_gene_list, split="_")
raw_gene_list_no_eco = sapply(split_raw_genes, function(x) paste(x[-1],collapse="_"))
raw_gene_prokka_id = sapply(split_raw_genes,function(x) x[2])
raw_gene_list_df = data.frame(raw_gene_list_no_eco,raw_gene_prokka_id)
raw_gene_list_dt= as.data.table(raw_gene_list_df)
setkey(raw_gene_list_dt,raw_gene_prokka_id)
unique_prokka_ids = unique(raw_gene_prokka_id)
# get ecology of every raw gene
raw_gene_ecologies = sapply(split_raw_genes, function(x) x[1])
num_genes_each_ecology = table(raw_gene_ecologies)
num_genes_each_ecology_df = data.frame(names(num_genes_each_ecology),as.numeric(num_genes_each_ecology))
gene_numbers_each_sample = mclapply(all_annotation_files, function(x)  {
  annotation_df_temp = fread(x,sep="\t",header=TRUE,fill=TRUE)
  total_num_genes = nrow(annotation_df_temp)
  # only keep species level annotations
  annotation_df_temp = annotation_df_temp[species != "no support" & !is.na(species) & species!=""]
  # remove uncultured bacterium
  annotation_df_temp = annotation_df_temp[species != "uncultured bacterium"]
  # species IDs
  #speciesIDs = strsplit(annotation_df_temp$lineage,split=";")
  #speciesIDs = sapply(speciesIDs, function(x) x[length(x)])
  #species_annotations = annotation_df_temp$species
  # remove stars
  annotation_df_temp$species = gsub("*","",annotation_df_temp$species,fixed=TRUE)
  #annotation_df_temp$speciesIDs = speciesIDs
  
  # now get sample name
  sampleBasename = basename(x)
  sampleName = gsub("_prokka_out.ORF2LCA_named.txt","",sampleBasename)
  sampleName = gsub("_tax_names_annotated.txt","",sampleName)
  
  if(sampleName%in%sample_metadata$prokka_id) {
    metadata_index = match(sampleName,sample_metadata$prokka_id)
    sampleName = sample_metadata[metadata_index,"sample"]
    prokka_name = sample_metadata[metadata_index,"prokka_id"]
  } else {
    metadata_index = match(sampleName,sample_metadata$sample)
    prokka_name = sample_metadata[metadata_index,"prokka_id"]
  }
    # match sample name to biome
  biome = sample_metadata[match(sampleName,sample_metadata$sample),"ecology",]

  # load in mapping file
  mapping_file_temp = gene_mapping_files_df[match(sampleName,gene_mapping_files_df[,1]),2]
  if(!is.na(mapping_file_temp)) {
    mapping_df_temp = fread(mapping_file_temp,header=FALSE,sep="\t",data.table=FALSE)
    actual_gene_name = mapping_df_temp[match(annotation_df_temp$`# ORF`,mapping_df_temp[,2]),"V1"]
    annotation_df_temp$actual_gene_name = actual_gene_name
  } else {
    annotation_df_temp$actual_gene_name = sapply(strsplit(annotation_df_temp$`# ORF`,split="_"), function(x) paste(x[-1],collapse="_"))
  }
  # only keep genes in raw_gene_list
  sample_has_raw_genes = prokka_name%in%unique_prokka_ids
  if(sample_has_raw_genes == TRUE) {
    raw_gene_list_df_temp = raw_gene_list_dt[prokka_name]
    genes_to_keep = intersect(raw_gene_list_df_temp$raw_gene_list_no_eco,annotation_df_temp$actual_gene_name)
    if(length(genes_to_keep)>0) {
      setkey(annotation_df_temp,actual_gene_name)
      annotation_df_temp = annotation_df_temp[genes_to_keep]
      annotation_df_temp_summary = annotation_df_temp[,.N,by=.(phylum,species)]
      annotation_df_temp_summary$biome = biome
      return(annotation_df_temp_summary)
    } else {
      return(NULL) 
    }
  } else {
    return(NULL)    
  }
},mc.cores=10,mc.preschedule = FALSE)

saveRDS(gene_numbers_each_sample,"gene_numbers_each_sample_human_non_gut_specific.rds")
saveRDS(raw_gene_list_dt,"human_non_gut_raw_genes_dt.rds")
saveRDS(num_genes_each_ecology_df,"num_genes_each_ecology_df_human_non_gut.rds")

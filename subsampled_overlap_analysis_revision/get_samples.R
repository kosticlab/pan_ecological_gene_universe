args = commandArgs(trailingOnly=TRUE)

num_samples_each_ecology = as.numeric(args[1]) # max 4
output_dir=args[2]

metadata=read.csv("/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/human_env_metadata_may_7_2021.csv",header=TRUE)

set.seed(123)

for(x in 1:50) {
  df_sampled = do.call("rbind",lapply(split(metadata,metadata$ecology), function(df_temp) {
  my_df = df_temp[sample(nrow(df_temp), num_samples_each_ecology), ]
  df_edited = my_df[,c("sample","prokka_id","ecology","human_env_nonhumanhost","raw_orf_count","clustered_30perc_gene_number")]
  return(df_edited)
  }))
  df_sampled = as.data.frame(df_sampled)
  all_paths = apply(df_sampled,1, function(myrow) {
    if(myrow["human_env_nonhumanhost"] == "HUMAN") {
      pathName = paste("/n/scratch3/users/v/vnl3/_RESTORE/orfleton_v2_prokka_output/",myrow["sample"],"_prokka_out.tar.gz",sep="")
    } else {
      pathName = paste("/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/env_faa_files/",myrow["prokka_id"],".fasta",sep="")
    }
  })
  df_sampled$path = all_paths
  write.csv(df_sampled,paste(output_dir,"/","iteration",x,".csv",sep=""),row.names=FALSE)
}

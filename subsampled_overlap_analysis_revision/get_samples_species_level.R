args = commandArgs(trailingOnly=TRUE)

num_samples_each_ecology = as.numeric(args[1]) # max 4
output_dir=args[2]

metadata=read.table("/n/data1/joslin/icrb/kostic/szimmerman/OV2_fig3_4_complete_linkage/redone_ecology_comparison_heatmap/all_potential_kraken_input_samples.txt",header=FALSE)
colnames(metadata) = c("sample","ecology")
set.seed(123)

for(x in 1:50) {
  df_sampled = do.call("rbind",lapply(split(metadata,metadata$ecology), function(df_temp) {
  my_df = df_temp[sample(nrow(df_temp), num_samples_each_ecology), ]
  return(my_df)
  }))
  df_sampled = as.data.frame(df_sampled)
  write.csv(df_sampled,paste(output_dir,"/","iteration",x,".csv",sep=""),row.names=FALSE)
}

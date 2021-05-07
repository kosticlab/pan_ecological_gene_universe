import pandas as pd
import os
files=os.listdir('.')
files=[x for x in files if 'multi_map_30_sample' in x]

output=[]
for f in files:
	output.append(pd.read_csv(f,sep='\t',index_col=0))

output=pd.concat(output,axis=1).fillna(0)

output.to_csv('subsampled_overlap_analysis.tsv',sep='\t')

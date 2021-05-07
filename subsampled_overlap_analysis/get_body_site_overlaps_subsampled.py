###iterative sampling parallel for conserved genes
##Tierney
#20200319

import pandas as pd
import sys
import os
import random
from collections import Counter
import multiprocessing as mp
import numpy as np

def run_sampling(i):
	global all_samples
	global data
	global sample_size
	global shuffle
	subsample=[]
	for x in all_samples:
		subsample.extend(random.sample(x,sample_size))
	data2=data.loc[subsample,:]
	data2.index=range(len(data2.index))
	print('Text cleaned')
	data2=data2.groupby(2)[1].apply(lambda x: '-'.join(sorted(list(set(x)))))
	data2=pd.DataFrame.from_dict(Counter(data2),orient='index')
	data2.to_csv('%s_sample_%s_%s.csv'%('multi_map_30',shuffle,str(i)),sep='\t')
	return(data2)

i=sys.argv[1]
shuffle = sys.argv[2]

data=pd.read_csv('multi_map_30.tsv',sep='\t')
data.columns=[0,1]
print('Loaded')
data.index=data[1].str.split('_').str[1]
data[0]=data[0].str.split('_').str[0]

metadata = pd.read_csv('metadata_100_filtered.tsv',sep='\t',index_col=0)
all_samples_df = metadata.loc[:,['prokka_id','ecology']]

all_samples=[]
for val in list(set(all_samples_df.iloc[:,1])):
	all_samples.append(list(all_samples_df[all_samples_df.iloc[:,1]==val].iloc[:,0]))

sample_size = min([len(x) for x in all_samples])

####FOR PERMUTATION TEST, SHUFFLE ENVIRONMENTAL LABELS
if shuffle == 'TRUE':
	data.loc[:,1] = data.loc[:,1].sample(frac=1)
	data.loc[:,2] = data.loc[:,2].sample(frac=1)

#pool=mp.Pool(10)
#output=pool.map(run_sampling,range(10))
#pool.close()

run_sampling(i)
#output=pd.concat(output,axis=1).fillna(0)
#output.to_csv('subsampled_overlap_analysis.tsv',sep='\t')

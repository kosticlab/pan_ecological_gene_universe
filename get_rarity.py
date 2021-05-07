#get rarity  

import sys
import pandas as pd
from collections import Counter

inputfile = sys.argv[1]
mappingfile = sys.argv[2]

#inputfile = 'vagina_all_genes'
#mappingfile='xad'

print(inputfile)
print(mappingfile)

print('loading raw orfs')
inputdata=[]
with open(inputfile) as f:
	for i,line in enumerate(f):
		if '_' not in line:
			continue
		rawgene=line.rstrip().split('\t')[0]
		inputdata.append(rawgene)

inputdata=set(inputdata)

print('loading mapping data')
mapping_data=[]
with open(mappingfile) as f:
	for line in f:
		rawgene=line.rstrip().split('\t')[0]
		if rawgene in inputdata:
			mapping_data.append(line.rstrip().split('\t'))

mapping_data_df = pd.DataFrame(mapping_data)
"""
print('generating count dictionaries')
mapping_data_countdicts = []
olddict={}
for i in range(0,mapping_data_df.shape[1]):
	dict1 = Counter(list(mapping_data_df[i]))
	if i !=0:
		dict1 = sum((Counter(dict(x)) for x in [dict1,olddict]),Counter())
		dict1={k: v - 1 for k, v in dict1.items()}
		olddict=dict1
	else:
		olddict = dict1
	mapping_data_countdicts.append(dict1)
"""

print('generating count dictionaries')
mapping_data_countdicts = []
olddict={}
for i in range(0,mapping_data_df.shape[1]):
	mapping_data_countdict = Counter(list(mapping_data_df.iloc[:,i]))
	mapping_data_countdict = {k: v - 1 for k, v in mapping_data_countdict.items()}
	mapping_data_countdicts.append(mapping_data_countdict)

print('writing to file')
with open('%s_%s_rarity'%(inputfile,mappingfile),'w') as w:
	for row in mapping_data_df.iterrows():
		row = list(row[1])
		temp=[]
		temp.append(row[0])
		for i,x in enumerate(row[1:]):
			temp.append(str(mapping_data_countdicts[i+1][x]))
		w.write('\t'.join(temp)+'\n')
"""
out=[]
for row in mapping_data_df.iterrows():
	row = list(row[1])
temp=[]
temp.append(row[0])
for i,x in enumerate(row[1:]):
	print(i)
	print(x)
	temp.append(str(mapping_data_countdicts[i+1][x]))
	out.append(temp)
"""


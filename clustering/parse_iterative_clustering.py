###generate iterative clustering summary output
##20200213
#Tierney

#This is extremely slow and requires a massive amount of memory, but it will enable about 70% of the analysis needed for this paper.

import os
from collections import Counter
import pandas as pd
from collections import defaultdict

#find files
files=os.listdir('.')
files=[x for x in files if 'tsv' in x]
files=[x for x in files if 'multi' not in x]
files=[x for x in files if 'iterative' not in x]
files.sort()
files2=files[:2]
files2.reverse()
files=files[2:]
files=[files2[0]]+files+[files2[1]]
files.reverse()


print("Loading data and generating cluster frequency files.")

#load in each file as a dictionary
dictList=[]
dictListCounts=[]
initial_ids=[]
countframes=[]
for i,fi in enumerate(files):
	print(fi)
	d=defaultdict(list)
	#d2={}
	with open(fi) as f:
		for line in f:
			line=line.rstrip().split('\t')
			d[line[0]].append(line[1].split('_')[1])
			#d2[line[1]]=line[0]
			#d3[line[1]]=len(list(set(d[line[0]])))
			if i==0:
				initial_ids.append(line[1])
	d3={}
	for x in d.keys():
		d3[x]=len(list(set(d[x])))
	dictListCounts.append(d3)
	if i==0:
		initial_output=pd.DataFrame.from_dict(Counter(d3.values()),orient='index')
		#initial_output.to_csv('%s_pid_cluster_sizes.tsv'%fi.replace('.tsv',''),sep='\t')
		countframes.append(initial_output)
	else:
		outdict={}
		for g in dictListCounts[-1].keys():
			outdict[g]=sum([x[g]-1 for x in dictListCounts])+1
		output=pd.DataFrame.from_dict(Counter(outdict.values()),orient='index')
		#output.to_csv(fi+'_countdict'+'.csv',sep='\t')
		#output.to_csv('%s_pid_cluster_sizes.tsv'%fi,sep='\t')
		countframes.append(output)

countframes_merged=pd.concat(countframes,axis=1)
countframes_merged=countframes_merged.fillna(0)
countframes_merged.to_csv('iterative_cluster_sizes.tsv',sep='\t')

#print("Generating master list of clustering mapping.")

#merge output
#with open('iterative_linclust_output_cluster_tracker.tsv','w') as w:
#	for val in initial_ids:
#		outputLine=[]
#		outputLine.append(val)
#		val2=val
#		for j in range(len(dictList)):
#			dicto=dictList[j]
#			val2=dicto[val2]
#			outputLine.append(val2)
#		w.write('\t'.join(outputLine)+'\n')



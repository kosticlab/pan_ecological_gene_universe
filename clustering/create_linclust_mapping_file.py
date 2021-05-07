###map between linclust output
##20190819
#Tierney

import sys
import os
import multiprocessing as mp

#argument is a file containing the location of the files to be mapped together.

#eg in the following format (order matters) sans pound signs:

#clustering_output_100.tsv
#clustering_output_95.tsv
#clustering_output_90.tsv

files = []
with open(sys.argv[1]) as f:
	for line in f:
		files.append(line.rstrip())


def load_par(i):
	global files
	global values
	fi=files[i]
	d={}
	with open(fi) as f:
		print(fi)
		for line in f:
			line=line.rstrip().split('\t')
			if i==0:
				d[line[1]]=line[0]
			else:
				if line[1] in values: 
					d[line[1]]=line[0]
	if i==0:
		values=set(list(d.values()))
		return([d,values])
	else:
		return(d)

def load(i,values):
	global files
	fi=files[i]
	d={}
	with open(fi) as f:
		print(fi)
		for line in f:
			line=line.rstrip().split('\t')
			if i==0:
				d[line[1]]=line[0]
			else:
				if line[1] in values: 
					d[line[1]]=line[0]
				else:
					continue
	values=set(list(d.values()))
	return([d,values])

initialoutput,values=load_par(0)

dictList=[]
dictList.append(initialoutput)
for i in range(1,len(files)):
	out,values=load(i,values)
	dictList.append(out)

pool=mp.Pool(20)
dictList=pool.map(load_par,range(1,len(files)))
pool.close()


#merge output
with open('iterative_linclust_output_%s'%'test','w') as w:
	for val in list(dictList[0].keys()):
		outputLine=[]
		outputLine.append(val)
		val2=val
		for dicto in dictList:
			val2=dicto[val2]
			outputLine.append(val2)
		w.write('\t'.join(outputLine)+'\n')






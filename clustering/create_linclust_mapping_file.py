###map between linclust output
##20190819
#Tierney

import sys
import os
import multiprocessing as mp

#find files
files=os.listdir('.')
files=[x for x in files if 'iterative' not in x]
files=[x for x in files if 'tsv' in x] 
files.sort()
files2=files[:2]
files2.reverse()
files=files[2:]
files=[files2[0]]+files+[files2[1]]
files.reverse()

files[0]=sys.argv[1]


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
dictList=pool.map(load_par,range(1,4))
pool.close()

#dictList=[initialoutput]+dictList

"""
print(files)
#load in each file as a dictionary
dictList=[]
initial_ids=[]
for i,fi in enumerate(files):
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
	dictList.append(d)
"""

#merge output
with open('iterative_linclust_output_%s'%'test','w') as w:
	w.write('\t'.join(['100','95','90','85','80','75','70','65','60','55','50','45','40','35','30','25','20','15','10'])+'\n')
	for val in list(dictList[0].keys()):
		outputLine=[]
		outputLine.append(val)
		val2=val
		for dicto in dictList:
			val2=dicto[val2]
			outputLine.append(val2)
		w.write('\t'.join(outputLine)+'\n')






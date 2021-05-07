#count ntons
import pandas as pd
from collections import Counter
import sys

#load the processed multi map file
inputfile = sys.argv[1]

rawdata=[]
data = []
with open(inputfile) as f:
        for line in f:
#               rawdata.append(line)
                data.append('\t'.join([line.rstrip().split(',')[0],line.rstrip().split(',')[2]]))

data = list(set(data))
data = [x.split('\t')[1] for x in data] 

data=Counter(data)
data2= pd.DataFrame.from_dict(data,orient = 'index')

a=list(data.values())

foo=Counter(a)

bar = pd.DataFrame.from_dict(foo,orient = 'index')

bar.to_csv('nton_counts_%s.csv'%inputfile)
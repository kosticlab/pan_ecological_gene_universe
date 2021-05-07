import pandas as pd
import sys
import os
from collections import Counter

inputname=sys.argv[1]
data=pd.read_csv(inputname,sep='\t',header=None)
data.columns=[0,1]
print('Loaded')
data[0]=data[0].str.split('_').str[0]
print('Text cleaned')
#data[0]=data[0].apply(lambda x: x.split('__'))
#data=data.explode(0)
data=data.groupby(1)[0].apply(lambda x: '__'.join(sorted(list(set(x)))))

data.to_csv('bs_specific_map_%s'%sys.argv[1],sep='\t')
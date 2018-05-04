#!/bin/env python

import pandas as pd
import numpy as np
workfolder = '/scratch/user/gustapia06/FEA_PCE/models/'
MP = ['depth','length','width']

d = np.zeros(10)
l = np.zeros(10)
w = np.zeros(10)

for i in range(11,21):
    for j in MP:
        file = workfolder + 'model' + str(i) + '/melt_' + j + '.csv'

        data = pd.read_csv(file,header=None)
        a = float(data.mean(axis=0))
        if j[0]=='d':
            d[i-11] = a
        elif j[0]=='l':
            l[i-11] = a
        elif j[0]=='w':
            w[i-11] = a

all_data = pd.DataFrame({MP[0]: d, MP[1]: l, MP[2]: w})
newdata = pd.read_csv('/home/gustapia06/FEA_PCE/data/FEA_iter2.csv',header=0)
all_data = newdata.join(all_data)
print(all_data)
all_data.to_csv('/home/gustapia06/FEA_PCE/data/FEA_all_data.csv',mode='a',float_format='%.8e',index=False,header=False)

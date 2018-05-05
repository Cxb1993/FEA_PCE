import os
import re
import math
import sys

K = sys.argv[1]
wd = os.path.join(os.environ['SCRATCH'],'FEA_PCE','sweep','sweep'+K)
os.chdir(wd)
pattern = 'sweep\d+_mods'
files = [i for i in os.listdir('.') if re.search(pattern,i)]

n = len(files)
if n == 0:
    print('\nNo files found.\n')
    sys.exit()

pad0 = math.log10(n)
if pad0.is_integer():
    pad0 = int(pad0) + 1
else:
    pad0 = math.ceil(pad0)

for i in files:
    fn = i.split('_')
    filename = fn[0] + '_mods_' + fn[2].zfill(pad0) + '.mph'
    print('Renaming file ' + i + ' for ' + filename)
    os.rename(i,filename)

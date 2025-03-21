#!/usr/bin/python
from sys import argv
import os
import sys
import inspect
from tqdm import tqdm
import pickle
import matplotlib.pyplot as plt
import shutil
from scipy.signal import savgol_filter

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 
parentdir2 = os.path.dirname(parentdir)
sys.path.insert(0, parentdir2) 

dirname = os.path.dirname(__file__)
basename =os.path.basename(__file__)


from pyds.pyds import MassFunction
from tensords.tensords import TensorMassFunction
from tensords.tensords_mask import TensorMassFunctionMask
from tensords.tensords_mask_csr import TensorMassFunctionMask_CSR

from itertools import product
from TestTool import *


data = {}

fig, ax = plt.subplots()
ax: plt.Axes = ax

file = open(dirname+'/' +'20040516_tensords_speed_compare_baseline_data.pickle', 'rb')
data1 = pickle.load(file)
for k,v in data1.items(): 
    if len(v) >0: 
        data[k] = v
        x_baseline = [i['n'] for i in v][1:]
        y_baseline = [i['time'] for i in v][1:]
file.close()


file = open(dirname+'/' +'20040516_tensords_speed_compare_matrix_data.pickle', 'rb')
data1 = pickle.load(file)
for k,v in data1.items(): 
    if len(v) >0: 
        data[k] = v
        x_matrix = [i['n'] for i in v][1:]
        y_matrix = [i['time'] for i in v][1:]
        
        y_matrix = savgol_filter(y_matrix,2,1)
file.close()

file = open(dirname+'/' +'20040516_tensords_speed_compare_mask_data.pickle', 'rb')
data1 = pickle.load(file)
for k,v in data1.items(): 
    if len(v) >0: 
        data[k] = v
        x_mask = [i['n'] for i in v][1:]
        y_mask = [i['time'] for i in v][1:]
file.close()

file = open(dirname+'/' +'20040516_tensords_speed_compare_mask_csr_data.pickle', 'rb')
data1 = pickle.load(file)
for k,v in data1.items(): 
    if len(v) >0: 
        data[k] = v
        x_mask_csr = [i['n'] for i in v][1:]
        y_mask_csr = [i['time'] for i in v][1:]
file.close()


for i in range(1000):
    if i >= len(y_mask_csr): continue
    if i >= len(y_baseline): continue
    print(x_mask_csr[i],':', y_baseline[i]/y_mask_csr[i])



asd=123
ax.plot(x_baseline,y_baseline,label='Baseline')
ax.plot(x_matrix,y_matrix,label='TensorBF(matrix)')
ax.plot(x_mask,y_mask,label='TensorBF(mask)')
ax.plot(x_mask_csr,y_mask_csr,label='TensorBF(csr)')


ax.set_yscale('log')
ax.set_xlabel("$|\Omega|$")
ax.set_ylabel("Aggregating time (second)")
ax.legend()
from matplotlib.ticker import MaxNLocator
ax.xaxis.set_major_locator(MaxNLocator(integer=True))


fileName = dirname + '/' + basename.replace('.py','.png')
plt.savefig(fileName)

fileName = dirname + '/' + basename.replace('.py','.pdf')
plt.savefig(fileName)

fileName2 = "C:/Users/nmtoa/Dropbox/Apps/Overleaf/Toan_202405_Tensor_BeliefFunction/Figures/"+basename.replace('.py','.pdf')
shutil.copyfile(fileName,fileName2 )


plt.show()
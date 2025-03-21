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


from itertools import product
from TestTool import *


data = {}

fig, ax = plt.subplots()
ax: plt.Axes = ax

file = open(dirname+'/' +'data_20240530_complete_baseline.pickle', 'rb')
data1 = pickle.load(file)
x_baseline = [i['n'] for i in data1][1:]
y_baseline = [i['time'] for i in data1][1:]
file.close()


file = open(dirname+'/' +'data_20240530_complete_matrix.pickle', 'rb')
data1 = pickle.load(file)
x_matrix = [i['n'] for i in data1][1:]
y_matrix = [i['time'] for i in data1][1:]
#y_matrix = savgol_filter(y_matrix,2,1)
file.close()

file = open(dirname+'/' +'data_20240530_complete_mask.pickle', 'rb')
data1 = pickle.load(file)
x_mask = [i['n'] for i in data1][1:]
y_mask = [i['time'] for i in data1][1:]
file.close()

file = open(dirname+'/' +'data_20240530_complete_mask_csc.pickle', 'rb')
data1 = pickle.load(file)
x_mask_csc = [i['n'] for i in data1][1:]
y_mask_csc = [i['time'] for i in data1][1:]
file.close()

file = open(dirname+'/' +'data_20240530_complete_csc_wise.pickle', 'rb')
data1 = pickle.load(file)
x_csc_wise = [i['n'] for i in data1][1:]
y_csc_wise = [i['time'] for i in data1][1:]
file.close()



asd=123
ax.plot(x_baseline,y_baseline,label='Baseline')
ax.plot(x_matrix,y_matrix,label='TensorBF(matrix)')
ax.plot(x_mask,y_mask,label='TensorBF(mask)')
ax.plot(x_mask_csc,y_mask_csc,label='TensorBF(csc)')
ax.plot(x_csc_wise,y_csc_wise,label='TensorBF(csc-wise)')


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


mi_matrix = 1000000000; ma_matrix = -1000000000
mi_matrix_x = 1000000000; ma_matrix_x = -1000000000
mi_mask = 1000000000; ma_mask = -1000000000
mi_mask_x = 1000000000; ma_mask_x = -1000000000
mi_mask_csc = 1000000000; ma_mask_csc = -1000000000
mi_mask_csc_x = 1000000000; ma_mask_csc_x = -1000000000
mi_csc_wise = 1000000000; ma_csc_wise = -1000000000
mi_csc_wise_x = 1000000000; ma_csc_wise_x = -1000000000
for i in range(len(x_baseline)):
    
    if i < len(y_matrix):
        ratio = y_baseline[i]/y_matrix[i]
        if ratio<mi_matrix: mi_matrix = ratio; mi_matrix_x = x_baseline[i]
        if ratio>ma_matrix: ma_matrix = ratio; ma_matrix_x = x_baseline[i]
    

    if i < len(y_mask):
        ratio = y_baseline[i]/y_mask[i]
        if ratio<mi_mask: mi_mask = ratio; mi_mask_x = x_baseline[i]
        if ratio>ma_mask: ma_mask = ratio; ma_mask_x = x_baseline[i]
    

    if i < len(y_mask_csc):
        ratio = y_baseline[i]/y_mask_csc[i]
        if ratio<mi_mask_csc: mi_mask_csc = ratio; mi_mask_csc_x = x_baseline[i]
        if ratio>ma_mask_csc: ma_mask_csc = ratio; ma_mask_csc_x = x_baseline[i]
   

    if i < len(y_csc_wise):
        ratio = y_baseline[i]/y_csc_wise[i]
        if ratio<mi_csc_wise: mi_csc_wise = ratio; mi_csc_wise_x = x_baseline[i]
        if ratio>ma_csc_wise: ma_csc_wise = ratio; ma_csc_wise_x = x_baseline[i]

print(f'y_matrix: {mi_matrix_x},{ma_matrix_x}', mi_matrix, ma_matrix)
print(f'y_mask: {mi_mask_x},{ma_mask_x}', mi_mask, ma_mask)
print(f'y_mask_csc: {mi_mask_csc_x},{ma_mask_csc_x}', mi_mask_csc, ma_mask_csc)
print(f'y_csc_wise: {mi_csc_wise_x},{ma_csc_wise_x}', mi_csc_wise, ma_csc_wise)
plt.show()
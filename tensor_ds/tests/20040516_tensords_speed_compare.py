#!/usr/bin/python
from sys import argv
import os
import sys
import inspect
from tqdm import tqdm
import pickle
import matplotlib.pyplot as plt
import shutil

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 
dirname = os.path.dirname(__file__)
basename =os.path.basename(__file__)

from pyds.pyds import MassFunction
from tensords.tensords import TensorMassFunction
from tensords.tensords_mask import TensorMassFunctionMask
from tensords.tensords_mask_csr import TensorMassFunctionMask_CSR

from itertools import product
from TestTool import *
params = { "text.usetex" : True,"font.family" : "serif", "font.serif" : ["Computer Modern Serif"]}


if True:
    n = 20
    output = {'baseline':[], 'matrix':[], 'mask':[], 'mask_csr':[] }
    try:
        for i in tqdm(range(2,n),'baseline'):
            frame,dicts,array = GenerateFullFrameOfDiscernment(i)
            frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
            time1 = time.time()
            m1 = MassFunction(dicts)
            m2 = MassFunction(dicts2)
            for j in range(1):  m1&m2
            time2 = time.time()
            output['baseline'].append({'n':i,'time': time2-time1 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
    except: print('error')


    try:
        for i in tqdm(range(2,n),'matrix'):
            frame,dicts,array = GenerateFullFrameOfDiscernment(i)
            tmp = TensorMassFunction.SetFrame(frame)
            frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
            time1 = time.time()
            tm1 = TensorMassFunction(array)
            tm2 = TensorMassFunction(array2)
            for j in range(1):  tm1.Combine(tm2)
            time2 = time.time()
            output['matrix'].append({'n':i,'time': time2-time1 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
    except: print('error')

    try:
        for i in tqdm(range(2,n),'mask'):
            frame,dicts,array = GenerateFullFrameOfDiscernment(i)
            tmp = TensorMassFunctionMask.SetFrame(frame)
            frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
            time1 = time.time()
            tmmask1 = TensorMassFunctionMask(array)
            tmmask2 = TensorMassFunctionMask(array2)
            for j in range(1):  tmmask1.Combine(tmmask2)
            time2 = time.time()
            output['mask'].append({'n':i,'time': time2-time1 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
    except: print('error')
    try:
        for i in tqdm(range(2,n),'mask_csr'):
            frame,dicts,array = GenerateFullFrameOfDiscernment(i)
            tmp = TensorMassFunctionMask_CSR.SetFrame(frame)
            frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
            time1 = time.time()
            tmmaskcsr1 = TensorMassFunctionMask_CSR(array)
            tmmaskcsr2 = TensorMassFunctionMask_CSR(array2)
            for j in range(1):  tmmaskcsr1.Combine(tmmaskcsr2)
            time2 = time.time()
            output['mask_csr'].append({'n':i,'time': time2-time1 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
    except Exception as e: print(e)







    exit(0)
else:
    file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'rb')
    data = pickle.load(file)
    file.close()

print(data)
fig, ax = plt.subplots()


x = [i['n'] for i in data][4:]
y1 = [i['time_baseline'] for i in data][4:]
y2 = [i['time_our'] for i in data][4:]

ratio = [i['time_baseline']/i['time_our'] for i in data][4:]
print(ratio)
ax.plot(x, y1,label='Baseline')
ax.plot(x, y2,label='Tensor (Proposed method)')
ax.legend()
ax.set_xlabel("$|\Omega|$")
ax.set_ylabel("Time (seconds)")
ax.set_xticks(x)





fig.tight_layout()


import os


fileName = dirname + '/Figures/' + basename.replace('.py','.png')
plt.savefig(fileName)

fileName = dirname + '/Figures/' + basename.replace('.py','.pdf')
plt.savefig(fileName)

fileName2 = "C:/Users/nmtoa/Dropbox/Apps/Overleaf/Toan_202405_Tensor_BeliefFunction/Figures/"+basename.replace('.py','.pdf')
shutil.copyfile(fileName,fileName2 )
plt.show()






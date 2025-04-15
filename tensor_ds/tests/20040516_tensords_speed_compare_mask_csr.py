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


n = 20
output = {'baseline':[], 'matrix':[], 'mask':[], 'mask_csr':[] }
# try:
#     for i in tqdm(range(2,n),'baseline'):
#         frame,dicts,array = GenerateFullFrameOfDiscernment(i)
#         frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
#         time1 = time.time()
#         m1 = MassFunction(dicts)
#         m2 = MassFunction(dicts2)
#         for j in range(1):  m1&m2
#         time2 = time.time()
#         output['baseline'].append({'n':i,'time': time2-time1 })
#         file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
# except: print('error')


# try:
#     for i in tqdm(range(2,n),'matrix'):
#         frame,dicts,array = GenerateFullFrameOfDiscernment(i)
#         tmp = TensorMassFunction.SetFrame(frame)
#         frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
#         time1 = time.time()
#         tm1 = TensorMassFunction(array)
#         tm2 = TensorMassFunction(array2)
#         for j in range(1):  tm1.Combine(tm2)
#         time2 = time.time()
#         output['matrix'].append({'n':i,'time': time2-time1 })
#         file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
# except: print('error')

# try:
#     for i in tqdm(range(2,n),'mask'):
#         frame,dicts,array = GenerateFullFrameOfDiscernment(i)
#         tmp = TensorMassFunctionMask.SetFrame(frame)
#         frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
#         time1 = time.time()
#         tmmask1 = TensorMassFunctionMask(array)
#         tmmask2 = TensorMassFunctionMask(array2)
#         for j in range(1):  tmmask1.Combine(tmmask2)
#         time2 = time.time()
#         output['mask'].append({'n':i,'time': time2-time1 })
#         file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
# except: print('error')
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




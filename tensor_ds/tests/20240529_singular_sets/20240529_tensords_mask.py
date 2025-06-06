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


n = 20
output = []

try:
    for i in tqdm(range(2,n),'mask'):
        frame,dicts,array = GenerateSingularrameOfDiscernment(i)
        tmp = TensorMassFunctionMask.SetFrame(frame)
        frame2,dicts2,array2 = GenerateSingularrameOfDiscernment(i)
        time1 = time.time()
        tmmask1 = TensorMassFunctionMask(array)
        tmmask2 = TensorMassFunctionMask(array2)
        for j in range(1):  tmmask1.Combine(tmmask2)
        time2 = time.time()
        output.append({'n':i,'time': time2-time1 })
        file = open(dirname+'/data_' +basename.replace('.py','.pickle'), 'wb'); pickle.dump(output,file ); file.close()
except: print('error')





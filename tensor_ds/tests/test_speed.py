#!/usr/bin/python
from sys import argv
import os
import sys
import inspect
from tqdm import tqdm
import pickle
import matplotlib.pyplot as plt
import shutil
import random
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 
dirname = os.path.dirname(__file__)
basename =os.path.basename(__file__)

from pyds.pyds import MassFunction
from tensords.tensords import TensorMassFunction
from tensords.tensords_mask import TensorMassFunctionMask


from itertools import product
from TestTool import *
params = { "text.usetex" : True,"font.family" : "serif", "font.serif" : ["Computer Modern Serif"]}


np.random.seed(3)
i = 15
frame,dicts,array = GenerateFullFrameOfDiscernment(i)
#tmp = TensorMassFunctionMask.SetFrame(frame)
frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
time1 = time.time()

tmmask1 = TensorMassFunctionMask(array)
tmmask2 = TensorMassFunctionMask(array2)

tmmask1.ConvertMassFuntionToVector()
tmmask2.ConvertMassFuntionToVector()


time3 = time.time()
for j in range(1):  
    tmmask3 = tmmask1.Combine(tmmask2)
time2 = time.time()

print('time mask:',time2-time3)
print(tmmask3.vec,'\n\n')





from tensords.cnndst import CNNDST
import torch
import time
torch.set_num_threads(1)

N = i


M = np.outer(array,array2)
M = np.array([[M]], dtype='float32')
M = torch.tensor(M)

cnndst = CNNDST(N)
cnndst.eval()
cnndst.warmup()

## cnndst
st = time.time()
with torch.no_grad():
    cnn_res = cnndst.forward(M)
cnn_res = cnndst.post_process_m(cnn_res)
cnn_res = cnn_res[0]
cnn_res /= 1 - cnn_res[0]
cnn_res[0] = 0

st2 = time.time()
print('time cnn:', st2-st)
print(cnn_res)





# m1 = MassFunction(dicts)
# m2 = MassFunction(dicts2)
# st = time.time()
# m3 = m1&m2
# st2 = time.time()
# print('\ntime baseline:', st2-st)

# tmmask_m3 = TensorMassFunctionMask(m3)
# print(tmmask_m3.vec)


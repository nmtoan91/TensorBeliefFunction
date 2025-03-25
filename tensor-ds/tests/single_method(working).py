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



if __name__ == '__main__':


        
    output = {'baseline':[], 'matrix':[], 'mask':[], 'mask_csr':[] }
    for i in tqdm(range(2,20)):
        frame,dicts,array = GenerateFullFrameOfDiscernment(i)
        tmp = TensorMassFunction.SetFrame(frame)
        tmp = TensorMassFunctionMask.SetFrame(frame)
        tmp = TensorMassFunctionMask_CSR.SetFrame(frame)

        frame2,dicts2,array2 = GenerateFullFrameOfDiscernment(i)
        
        

        m1 = MassFunction(dicts)
        m2 = MassFunction(dicts2)
        tm1 = TensorMassFunction(array)
        tm2 = TensorMassFunction(array2)

        tmmask1 = TensorMassFunctionMask(array)
        tmmask2 = TensorMassFunctionMask(array2)

        tmmaskcsr1 = TensorMassFunctionMask_CSR(array)
        tmmaskcsr2 = TensorMassFunctionMask_CSR(array2)

        time1 = time.time()

        try:
            for j in range(100):  m1&m2
            time2 = time.time()
            output['baseline'].append({'n':i,'time': time2-time1 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
        except: print('error')
        
        time2 = time.time()

        try:
            for j in range(100):  tm1.Combine(tm2)
            time3 = time.time()
            output['matrix'].append({'n':i,'time': time3-time2 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
        except: print('error')

        time3 = time.time()
        
        try:
            for j in range(100):  tmmask1.Combine(tmmask2)
            time4 = time.time()
            output['mask'].append({'n':i,'time': time4-time3 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
        except: print('error')

        time4 = time.time()

        try:
            for j in range(100):  tmmask1.Combine(tmmask2)
            time5 = time.time()
            output['mask_csr'].append({'n':i,'time': time5-time4 })
            file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb'); pickle.dump(output,file ); file.close()
        except: print('error')

        time5 = time.time()
        
        #data.append({"n":i, 'time_baseline':time2-time1, 'time_matrix':time3-time2, 'time_mask': time4-time3,'time_maskcsr':time5-time4   })

        

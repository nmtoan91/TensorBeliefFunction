import os
import sys
import inspect
import numpy as np

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

from pyds.pyds import MassFunction
from tensords.tensords import TensorMassFunction
#from tensords.tensords_csc import TensorMassFunction_CSC
from tensords.tensords_csc_wise import TensorMassFunction_CSC_Wise
from tensords.tensords_mask import TensorMassFunctionMask
from tensords.tensords_mask_csc import TensorMassFunctionMask_CSC
from itertools import product

print('=== creating mass functions ===')
m1 = MassFunction({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary

m2 = MassFunction({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionary

m12 = m1 & m2
print(m12)


tem1 = TensorMassFunction({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary
tem2 = TensorMassFunction({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
tem12 = tem1.Combine(tem2)
print(tem12.ConvertToOriginalMassFunction())



tm1 = TensorMassFunction_CSC_Wise({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary
tm2 = TensorMassFunction_CSC_Wise({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
tm12 = tm1.Combine(tm2)
print(tm12.ConvertToOriginalMassFunction())


tm1 = TensorMassFunctionMask({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary
tm2 = TensorMassFunctionMask({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
tm12 = tm1.Combine(tm2)
print(tm12.ConvertToOriginalMassFunction())


tm1 = TensorMassFunctionMask_CSC({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary
tm2 = TensorMassFunctionMask_CSC({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
tm12 = tm1.Combine(tm2)
print(tm12.ConvertToOriginalMassFunction())



from tensords.cnndst import CNNDST
import torch
import time
N = 3

#M = np.matmul(tem1.vec.transpose(),[tem2.vec])
M1 = np.matmul(np.array([tem1.vec]).transpose(),np.array([tem2.vec]))
M = np.outer(tem1.vec,tem2.vec)
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
print(cnn_res)


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
#from tensords.tensords import TensorMassFunction
#from tensords.tensords_mask import TensorMassFunctionMask

from TensorBeliefFunction.tensords import TensorMassFunction
from TensorBeliefFunction.tensords_mask import TensorMassFunctionMask
from itertools import product
from TestTool import *
params = { "text.usetex" : True,"font.family" : "serif", "font.serif" : ["Computer Modern Serif"]}
plt.rcParams.update(params)

if False:
    # data = []
    # for i in tqdm(range(2,11)):
    #     frame,dicts,array = GenerateFullFrameOfDiscernment(i)
    #     tmp = TensorMassFunction.SetFrame(frame)
    #     ts:TensorMassFunction = tmp
        
    #     n = len(array)
    #     matrixSize = n**3
    #     data.append({"n":i,"time_init": ts.time_init,
    #                  "time_generate_projection_matrix": ts.time_generate_projection_matrix,
    #                   "matrixsize": matrixSize })
    # print(data)
    # file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'wb')
    # pickle.dump(data,file )
    # file.close()


    data = []
    for i in tqdm(range(2,17)):
        frame,dicts,array = GenerateFullFrameOfDiscernment(i)
        tmp = TensorMassFunctionMask.SetFrame(frame)
        ts:TensorMassFunctionMask = tmp
        
        n = len(array)
        matrixSize = n*3
        data.append({"n":i,"time_init": ts.time_init,
                     "time_generate_projection_matrix": ts.time_generate_projection_matrix,
                      "matrixsize": matrixSize })
    print(data)
    file = open(dirname+'/' +basename.replace('.py','_data_mask.pickle'), 'wb')
    pickle.dump(data,file )
    file.close()

    exit(0)
else:
    file = open(dirname+'/' +basename.replace('.py','_data.pickle'), 'rb')
    data = pickle.load(file)
    file.close()

    file = open(dirname+'/' +basename.replace('.py','_data_mask.pickle'), 'rb')
    data2 = pickle.load(file)
    file.close()

print(data)
fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(5, 3))


x = [i['n'] for i in data]
y = [i['time_generate_projection_matrix'] for i in data]

x_mask = [i['n'] for i in data2]
y_mask = [i['time_generate_projection_matrix'] for i in data2]

st = 3
x_mask3= x_mask[st:]
y_mask3 = y_mask[st:]
x2 = x[st:]
y2 = y[st:]




axes[0].plot(x_mask3, y_mask3,label='mask')
axes[0].plot(x2, y2,label='matrix')
axes[0].set_yscale('log')
axes[0].set_xlabel("$|\Omega|$")
axes[0].set_ylabel("Time (seconds)")
axes[0].legend()
#axes[0].set_xticks(x_mask)



y = [i['matrixsize'] for i in data]

y_mask = [i['matrixsize'] for i in data2]
axes[1].plot(x_mask, y_mask,label='mask')
axes[1].plot(x, y,label='matrix')
axes[1].set_yscale('log')
axes[1].set_xlabel("$|\Omega|$")
axes[1].set_ylabel(r"Matrix size (row $\times$ col)")
axes[1].legend(loc='upper left')
#axes[1].set_xticks(y_mask)


fig.tight_layout()


import os


fileName = dirname + '/Figures/' + basename.replace('.py','.png')
plt.savefig(fileName)

fileName = dirname + '/Figures/' + basename.replace('.py','.pdf')
plt.savefig(fileName)

fileName2 = "D:/Dropbox/Apps/Overleaf/Toan_202405_Tensor_BeliefFunction/Figures/"+basename.replace('.py','.pdf')
shutil.copyfile(fileName,fileName2 )
plt.show()






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
# from tensords.tensords import TensorMassFunction


# from tensords.tensords_mask import TensorMassFunctionMask
# from tensords.tensords_mask_csr import TensorMassFunctionMask_CSR

#from TensorBeliefFunction.tensords.tensords import TensorMassFunction
#from TensorBeliefFunction.tensords.tensords_mask import TensorMassFunctionMask 
#from TensorBeliefFunction.tensords.tensords_mask_csr import TensorMassFunctionMask_CSR

#from TensorBeliefFunction.tensords import TensorMassFunction
#from TensorBeliefFunction.tensords_mask import TensorMassFunctionMask 
#from tensor_ds.tensords_mask_pythonloop import TensorMassFunctionMask
from tensords_mask_pythonloop2 import TensorMassFunctionMask


from itertools import product
from TestTool import *

params = { "text.usetex" : True,"font.family" : "serif", "font.serif" : ["Computer Modern Serif"]}
#plt.rcParams.update(params)

#from TensorBeliefFunction.tensords_mask_csc import TensorMassFunctionMask_CSC
params = { "text.usetex" : True,"font.family" : "serif", "font.serif" : ["Computer Modern Serif"]}
plt.rcParams.update(params)
n1 = 2
n = 6
size = n-n1



fig, axss = plt.subplots(2, 2, tight_layout=True)



for i in tqdm(range(2,n),'mask'):


    frame,dicts,array = GenerateSingularrameOfDiscernment(i)
    tmp = TensorMassFunctionMask.SetFrame(frame)
    x = TensorMassFunctionMask.projectionMask
    unique, counts = np.unique(x, return_counts=True)
    

    
    percent = 100*counts[0]/sum(counts)
    if i ==2: 
        axs = axss[0,0]
        axs.set_title("$\Omega=\{$`a',`b'$\}$ (\%$\emptyset=$" + "{:.1f}".format(percent) + "\%1)")
    elif i ==3: 
        axs = axss[0,1]
        axs.set_title("$\Omega=\{$`a',`b',`c'$\}$ (\%$\emptyset=$" +  "{:.1f}".format(percent)+ "\%)")
    elif i ==4: 
        axs = axss[1,0]
        axs.set_title("$\Omega=\{$`a',`b',`c',`d'$\}$ (\%$\emptyset=$" + "{:.1f}".format(percent)+ "\%)")
    elif i ==5: 
        axs = axss[1,1]
        axs.set_title("$\Omega=\{$`a',`b',`c',`d',`e'$\}$ (\%$\emptyset=$" + "{:.1f}".format(percent)+ "\%)")
    

    axs: plt.Axes = axs
    #axs.set_title("$|\Omega|=$" + str(i))
    axs.bar(unique,counts)
    axs.bar([unique[0]],[counts[0]])
    
    ticks = axs.get_xticks()
    ticklabels = axs.get_xticklabels()
    labels = [item.get_text() for item in axs.get_xticklabels()]
    asd=123
    
    tickvalue_run = 0 
    for i in range(len(labels)):
        if labels[i] == '−1':
            labels[i] = "$\emptyset$"; continue
        if labels[i].find('−') >=0: continue
        #tickvalue = int(labels[i])
        tickvalue = tickvalue_run
        tickvalue_run+=1
        if tickvalue >= len(TensorMassFunctionMask.sortedPowerset):
            labels[i] = ""; continue
        
        myset = TensorMassFunctionMask.sortedPowerset[tickvalue]
        myset2 = TensorMassFunctionMask.setMapInt2Char[myset]
        mysetname = ""
        for e in myset:
            mysetname += frame[e]
        labels[i] = mysetname


    axs.set_xticklabels(labels)
    trans = axs.get_xaxis_transform()

    #axs.text(-1,-1,"$\emptyset$",horizontalalignment='center',
     #   verticalalignment='top' )

    axs.annotate('$\emptyset$', xy=(-0.9, -0.098), xycoords=axs.get_xaxis_transform(),
                   xytext=(0,0), textcoords="offset points", ha="right", va="center")
        
    asd=123

fileName = dirname + '/' + basename.replace('.py','.png')
plt.savefig(fileName)

fileName = dirname + '/' + basename.replace('.py','.pdf')
plt.savefig(fileName)

fileName2 = "D:/Dropbox/Apps/Overleaf/Toan_202405_Tensor_BeliefFunction/Figures/"+basename.replace('.py','.pdf')
shutil.copyfile(fileName,fileName2 )


plt.show()
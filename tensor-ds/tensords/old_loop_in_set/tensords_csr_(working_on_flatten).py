from __future__ import print_function
from itertools import chain, combinations
from functools import partial, reduce
from operator import mul
from math import log, fsum, sqrt
from random import random, shuffle, uniform
import sys
import numpy as np
from sklearn.preprocessing import normalize
import time

from scipy.sparse import csr_matrix
from scipy.sparse import lil_matrix



class TensorMassFunction_CSR(dict):
    def __init__(self, source=None):
        self.vec = None
        

        if source is not None:
            if type(source)==np.ndarray:
                self.vec = csr_matrix(source,blocksize=source.shape)
                return
            if isinstance(source, dict):
                source = source.items()
            for (h, v) in source:
                self[h] += v
    
    sortedPowerset = None
    setMap = None
    setMapChar2Int = {}
    setMapInt2Char = {}
    projectionMatrix = None
    def __missing__(self, key):
        return 0.0
    def __getitem__(self, hypothesis):
        return dict.__getitem__(self, TensorMassFunction_CSR._convert(hypothesis))
    
    def __setitem__(self, hypothesis, value):
        """
        Adds or updates the mass value of a hypothesis.
        
        'hypothesis' is automatically converted to a 'frozenset' meaning its elements must be hashable.
        In case of a negative mass value, a ValueError is raised.
        """
        if value < 0.0:
            raise ValueError("mass value is negative: %f" % value)
        dict.__setitem__(self, TensorMassFunction_CSR._convert(hypothesis), value)
    
    def __delitem__(self, hypothesis):
        return dict.__delitem__(self, TensorMassFunction_CSR._convert(hypothesis))
    @staticmethod
    def _convert(hypothesis):
        """Convert hypothesis to a 'frozenset' in order to make it hashable."""
        if isinstance(hypothesis, frozenset):
            return hypothesis
        else:
            return frozenset(hypothesis)
    def frame(self):
        """
        Returns the frame of discernment of the mass function as a 'frozenset'.
        
        The frame of discernment is the union of all contained hypotheses.
        In case the mass function does not contain any hypotheses, an empty set is returned.
        """
        if not self:
            return frozenset()
        else:
            return frozenset.union(*self.keys())
    def powerset(self,iterable):
        """
        Returns an iterator over the power set of 'set'.
        
        'set' is an arbitrary iterator over hashable elements.
        All returned subsets are of type 'frozenset'.
        """
        return map(frozenset, chain.from_iterable(combinations(iterable, r) for r in range(len(iterable) + 1)))
    def GetSortedFrame(self):
        frame = self.frame()
        frameList = list(frame)
        frameList.sort()
        return frameList
    
    @staticmethod
    def SetFrame(frame): 
        TensorMassFunction_CSR.sortedPowerset = None
        TensorMassFunction_CSR.setMap = None
        TensorMassFunction_CSR.setMapChar2Int = {}
        TensorMassFunction_CSR.setMapInt2Char = {}
        TensorMassFunction_CSR.projectionMatrix = None
        mydict = {k:0.0 for k in frame}
        tmp = TensorMassFunction_CSR(mydict)
        tmp.GetSortedPowerset()
        return tmp

    def GetSortedPowerset(self):
        if TensorMassFunction_CSR.sortedPowerset != None:
            return TensorMassFunction_CSR.sortedPowerset
        time_start = time.time()
        sortFrame = self.GetSortedFrame()
        n = len(sortFrame)
        result = []
        for i in range(1, 2**n):
            combo = []
            for j in range(n):
                if i & (1 << j):
                    combo.append(j)
            
            comboChar = frozenset([sortFrame[k] for k in combo])
            combo = frozenset(combo)
            TensorMassFunction_CSR.setMapChar2Int[comboChar] = combo
            TensorMassFunction_CSR.setMapInt2Char[combo] = comboChar
            
            result.append(combo)
        result.sort(key=lambda x: (len(x), x))
        TensorMassFunction_CSR.sortedPowerset = result
        TensorMassFunction_CSR.setMap = {result[i]:i for i in range(len(result))    }
        time_generate_projection_matrix = time.time()
        self.GenerateProjectionMatrix()
        self.time_init = time.time() - time_start
        self.time_generate_projection_matrix = time.time() - time_generate_projection_matrix
        return  result
    
    def ConvertMassFuntionToVector(self):
        if self.vec is not None: return self.vec
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        #V = np.zeros((n))
        V = lil_matrix((n,1))
        #V = lil_array((n,1))
        for k,v in self.items():
            k_int = TensorMassFunction_CSR.setMapChar2Int[k]
            index = TensorMassFunction_CSR.setMap[k_int]
            V[index,0] = v
        self.vec = V.tocsr()
        return self.vec
    def AssignVector(self,V):
        self.vec = V
    
    def GenerateProjectionMatrix(self):
        if TensorMassFunction_CSR.projectionMatrix is not None: return TensorMassFunction_CSR.projectionMatrix
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        m = n*n
        #pMatrix = np.zeros((m,n))
        pMatrix = lil_matrix((m, n))
        index =-1
        for set1 in sortedPowerset:
            for set2 in sortedPowerset:
                index+=1
                intersecs = frozenset([value for value in set1 if value in set2])
                if len(intersecs)==0 : continue
                setIndex = TensorMassFunction_CSR.setMap[intersecs]
                pMatrix[index,setIndex] = 1
        TensorMassFunction_CSR.projectionMatrix = pMatrix.tocsr()
        return pMatrix

    

    def Combine(self,other):
        pMatrix = self.GenerateProjectionMatrix()
        other:TensorMassFunction_CSR = other

        v1 = self.ConvertMassFuntionToVector()
        v2 = other.ConvertMassFuntionToVector()
       
        
        m2 = np.matmul(np.outer(v1,v2.T).flatten(),pMatrix)
        m3 = m2/np.sum(m2)
        

        return TensorMassFunction_CSR(m3)

    def ConvertToOriginalMassFunction(self):
        sortedPowerset = self.GetSortedPowerset()
        for i in range(len(self.vec)):
            v = self.vec[i] 
            if v == 0: continue
            k = TensorMassFunction_CSR.setMapInt2Char[sortedPowerset[i]]
            self[k] = v
            

        

if __name__ == '__main__':
    TensorMassFunction_CSR.SetFrame(['a','b','c'])

    tm1 = TensorMassFunction_CSR({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary

    tm2 = TensorMassFunction_CSR({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
    elements = ['a', 'b', 'c', 'd']
    
    m12 = tm1.Combine(tm2)
    
    m12.ConvertToOriginalMassFunction()
    print(m12)


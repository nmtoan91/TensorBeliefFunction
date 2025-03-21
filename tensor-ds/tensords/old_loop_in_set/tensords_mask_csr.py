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
from scipy.sparse import issparse
class TensorMassFunctionMask_CSR(dict):
    def __init__(self, source=None):
        self.vec = None
        if source is not None:
            if type(source)==np.ndarray:
                self.vec = csr_matrix(source) 
                if self.vec.shape[1]>self.vec.shape[0]:
                    self.vec = self.vec.transpose()
                return
            if issparse(source):
                self.vec = source
                return

            if isinstance(source, dict):
                source = source.items()
            for (h, v) in source:
                self[h] += v
    
    sortedPowerset = None
    setMap = None
    setMapChar2Int = {}
    setMapInt2Char = {}
    projectionMask = None
    def __missing__(self, key):
        return 0.0
    def __getitem__(self, hypothesis):
        return dict.__getitem__(self, TensorMassFunctionMask_CSR._convert(hypothesis))
    
    def __setitem__(self, hypothesis, value):
        """
        Adds or updates the mass value of a hypothesis.
        
        'hypothesis' is automatically converted to a 'frozenset' meaning its elements must be hashable.
        In case of a negative mass value, a ValueError is raised.
        """
        if value < 0.0:
            raise ValueError("mass value is negative: %f" % value)
        dict.__setitem__(self, TensorMassFunctionMask_CSR._convert(hypothesis), value)
    
    def __delitem__(self, hypothesis):
        return dict.__delitem__(self, TensorMassFunctionMask_CSR._convert(hypothesis))
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
        TensorMassFunctionMask_CSR.sortedPowerset = None
        TensorMassFunctionMask_CSR.setMap = None
        TensorMassFunctionMask_CSR.setMapChar2Int = {}
        TensorMassFunctionMask_CSR.setMapInt2Char = {}
        TensorMassFunctionMask_CSR.projectionMask = None
        mydict = {k:0.0 for k in frame}
        tmp = TensorMassFunctionMask_CSR(mydict)
        tmp.GetSortedPowerset()
        return tmp

    def GetSortedPowerset(self):
        if TensorMassFunctionMask_CSR.sortedPowerset != None:
            return TensorMassFunctionMask_CSR.sortedPowerset
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
            TensorMassFunctionMask_CSR.setMapChar2Int[comboChar] = combo
            TensorMassFunctionMask_CSR.setMapInt2Char[combo] = comboChar
            
            result.append(combo)
        result.sort(key=lambda x: (len(x), x))
        TensorMassFunctionMask_CSR.sortedPowerset = result
        TensorMassFunctionMask_CSR.setMap = {result[i]:i for i in range(len(result))    }
        time_generate_projection_matrix = time.time()
        self.GenerateProjectionMask()
        self.time_init = time.time() - time_start
        self.time_generate_projection_matrix = time.time() - time_generate_projection_matrix
        return  result
    
    def ConvertMassFuntionToVector(self):
        if self.vec is not None: return self.vec
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        #V = np.zeros((n))
        V = lil_matrix((n,1))
        for k,v in self.items():
            k_int = TensorMassFunctionMask_CSR.setMapChar2Int[k]
            index = TensorMassFunctionMask_CSR.setMap[k_int]
            V[index,0] = v
        self.vec = V.tocsr()
        return self.vec
    
    def AssignVector(self,V):
        self.vec = V
    
    def GenerateProjectionMask(self):
        if TensorMassFunctionMask_CSR.projectionMask is not None: 
            return TensorMassFunctionMask_CSR.projectionMask
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        maskMatrix = np.zeros((n,n),dtype=int)
        #maskMatrix = lil_matrix((n, n),dtype=int)
        i =-1
        
        for set1 in sortedPowerset:
            i+= 1
            j = -1
            for set2 in sortedPowerset:
                j+=1 
                intersecs = frozenset([value for value in set1 if value in set2])
                if len(intersecs)==0 :
                    maskMatrix[i,j] = -1
                    continue
                setIndex = TensorMassFunctionMask_CSR.setMap[intersecs]
                maskMatrix[i,j] = setIndex
        TensorMassFunctionMask_CSR.projectionMask = maskMatrix
        return maskMatrix

    

    def Combine(self,other):
        pMatrix = self.GenerateProjectionMask()
        other:TensorMassFunctionMask_CSR = other

        v1 = self.ConvertMassFuntionToVector()
        v2 = other.ConvertMassFuntionToVector()
        
        m2 = v1*v2.T


        #m3 = np.zeros((len(m2)))
        m3 = lil_matrix((m2.shape[0],1))
        sum = 0
        #n = m2.shape[0]
        # for i in range(n):
        #     for j in range(n):
        #         if pMatrix[i,j] <0: continue
        #         m3[pMatrix[i,j]] += m2[i,j]
        # m3 = m3/np.sum(m3)

        rows,cols = m2.nonzero()
        for i,j in zip(rows,cols):
            if pMatrix[i,j] <0: continue
            v = m2[i,j]
            m3[pMatrix[i,j],0] += v
            sum+= v

       
            
           
        m3/=sum



        return TensorMassFunctionMask_CSR(m3)

    def ConvertToOriginalMassFunction(self):
        sortedPowerset = self.GetSortedPowerset()
        rows,cols = self.vec.nonzero()
        for i,j in zip(rows,cols):
            v = self.vec[i,0] 
            if v == 0: 
                continue
            k = TensorMassFunctionMask_CSR.setMapInt2Char[sortedPowerset[i]]
            self[k] = v
        return self

        

if __name__ == '__main__':
    TensorMassFunctionMask_CSR.SetFrame(['a','b','c'])

    tm1 = TensorMassFunctionMask_CSR({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary

    tm2 = TensorMassFunctionMask_CSR({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
    elements = ['a', 'b', 'c', 'd']
    
    m12 = tm1.Combine(tm2)
    
    m12.ConvertToOriginalMassFunction()
    print(m12)


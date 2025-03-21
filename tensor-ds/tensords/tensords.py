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


class TensorMassFunction(dict):
    def __init__(self, source=None):
        self.vec = None
        

        if source is not None:
            if type(source)==np.ndarray:
                self.vec = source
                return
            if isinstance(source, dict):
                source = source.items()
            for (h, v) in source:
                self[h] += v
            self.ConvertMassFuntionToVector()
    
    sortedPowerset = None
    setMap = None
    setMapChar2Int = {}
    setMapInt2Char = {}
    projectionMatrix = None
    def __missing__(self, key):
        return 0.0
    def __getitem__(self, hypothesis):
        return dict.__getitem__(self, TensorMassFunction._convert(hypothesis))
    
    def __setitem__(self, hypothesis, value):
        """
        Adds or updates the mass value of a hypothesis.
        
        'hypothesis' is automatically converted to a 'frozenset' meaning its elements must be hashable.
        In case of a negative mass value, a ValueError is raised.
        """
        if value < 0.0:
            raise ValueError("mass value is negative: %f" % value)
        dict.__setitem__(self, TensorMassFunction._convert(hypothesis), value)
    
    def __delitem__(self, hypothesis):
        return dict.__delitem__(self, TensorMassFunction._convert(hypothesis))
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
        TensorMassFunction.sortedPowerset = None
        TensorMassFunction.setMap = None
        TensorMassFunction.setMapChar2Int = {}
        TensorMassFunction.setMapInt2Char = {}
        TensorMassFunction.projectionMatrix = None
        mydict = {k:0.0 for k in frame}
        tmp = TensorMassFunction(mydict)
        tmp.GetSortedPowerset()
        return tmp
    def list_of_ones(self,n):
        result = []
        position = 0
        while n > 0:
            if n & 1:
                result.append(position)
            n >>= 1
            position += 1
        return result
    
    def GetSortedPowerset(self):
        if TensorMassFunction.sortedPowerset != None:
            return TensorMassFunction.sortedPowerset
        time_start = time.time()
        sortFrame = self.GetSortedFrame()
        n = len(sortFrame)
        result = []
        for i in range(0, 2**n):
            combo = self.list_of_ones(i)
            comboChar = frozenset([sortFrame[k] for k in combo])
            combo = frozenset(combo)
            result.append(combo)
            TensorMassFunction.setMapChar2Int[comboChar] = combo
            TensorMassFunction.setMapInt2Char[combo] = comboChar
        
        TensorMassFunction.sortedPowerset = result
        TensorMassFunction.setMap = {result[i]:i for i in range(len(result))    }
        time_generate_projection_matrix = time.time()
        self.GenerateProjectionMatrix()
        self.time_init = time.time() - time_start
        self.time_generate_projection_matrix = time.time() - time_generate_projection_matrix
        return  result
    
    def ConvertMassFuntionToVector(self):
        if self.vec is not None: return self.vec
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        V = np.zeros((n))
        for k,v in self.items():
            k_int = TensorMassFunction.setMapChar2Int[k]
            index = TensorMassFunction.setMap[k_int]
            V[index] = v
        self.vec = V
        return V
    def AssignVector(self,V):
        self.vec = V
    
    def GenerateProjectionMatrix(self):
        if TensorMassFunction.projectionMatrix is not None: return TensorMassFunction.projectionMatrix
        sortedPowerset = self.GetSortedPowerset()
        n_powerset = len(sortedPowerset)
        n = len(sortedPowerset)
        m = n*n
        pMatrix = np.zeros((m,n))
        index = -1
        for i in range(n_powerset):
            for j in range(n_powerset):
                index+=1
                intersecs = i&j
                setIndex = intersecs
                pMatrix[index,setIndex] = 1
        TensorMassFunction.projectionMatrix = pMatrix
        return pMatrix

    

    def Combine(self,other):
        pMatrix = self.GenerateProjectionMatrix()
        other:TensorMassFunction = other

        v1 = self.ConvertMassFuntionToVector()
        v2 = other.ConvertMassFuntionToVector()
        
        
        m2 = np.matmul(np.outer(v1,v2).flatten(),pMatrix)
        m2[0] = 0
        m3 = m2/np.sum(m2)
        

        return TensorMassFunction(m3)

    def ConvertToOriginalMassFunction(self):
        sortedPowerset = self.GetSortedPowerset()
        for i in range(len(self.vec)):
            v = self.vec[i] 
            if v == 0: continue
            k = TensorMassFunction.setMapInt2Char[sortedPowerset[i]]
            self[k] = v
        return self
    
    # def core(self):
    #     cor = []
    #     for i in self:
    #         cor.append(i)
    #     return cor

    def bel(self, hypothesis=None):
        if hypothesis is None:
            return {h:self.bel(h) for h in  TensorMassFunction.setMapChar2Int.keys()}
        else:
            k_int = TensorMassFunction.setMapChar2Int[frozenset(hypothesis)]
            index = TensorMassFunction.setMap[k_int]
            val = 0
            for i in range(1,len(self.vec)):
                if i&index == i:
                    val += self.vec[i]
            return val
        
        
    def pl(self, hypothesis=None):
        if hypothesis is None:
            return {h:self.pl(h) for h in  TensorMassFunction.setMapChar2Int.keys()}
        else:
            k_int = TensorMassFunction.setMapChar2Int[frozenset(hypothesis)]
            index = TensorMassFunction.setMap[k_int]
            val = 0
            for i in range(1,len(self.vec)):
                if i&index > 0:
                    val += self.vec[i]
            return val
        
    def pignistic(self):
        values = {}
        for i in range(1,len(self.vec)):
            if self.vec[i] == 0: continue
            list_of_ones = self.list_of_ones(i)
            for j in list_of_ones:
                if j not in values:
                    values[j] = 0
                values[j] += self.vec[i]/len(list_of_ones)
        valuesChar = {}
        for k,v in values.items():
            scalar = 1 << k
            fset =  self.sortedPowerset[scalar]
            fsetChar = self.setMapInt2Char[fset]
            valuesChar[fsetChar] = v
        return valuesChar
                
      

        

if __name__ == '__main__':
    TensorMassFunction.SetFrame(['a','b','c'])

    tm1 = TensorMassFunction({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary
    # print(tm1.list_of_ones(1))
    # print(tm1.list_of_ones(234234))
    # print(tm1.list_of_ones(23425345))

    # exit(0)
    tm2 = TensorMassFunction({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
    elements = ['a', 'b', 'c', 'd']
    
    m12 = tm1.Combine(tm2)
    
    m12.ConvertToOriginalMassFunction()
    print(m12)


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


class TensorMassFunctionMask(dict):
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
    #projectionMask = None
    def __missing__(self, key):
        return 0.0
    def __getitem__(self, hypothesis):
        return dict.__getitem__(self, TensorMassFunctionMask._convert(hypothesis))
    
    def __setitem__(self, hypothesis, value):
        """
        Adds or updates the mass value of a hypothesis.
        
        'hypothesis' is automatically converted to a 'frozenset' meaning its elements must be hashable.
        In case of a negative mass value, a ValueError is raised.
        """
        if value < 0.0:
            raise ValueError("mass value is negative: %f" % value)
        dict.__setitem__(self, TensorMassFunctionMask._convert(hypothesis), value)
    
    def __delitem__(self, hypothesis):
        return dict.__delitem__(self, TensorMassFunctionMask._convert(hypothesis))
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
        TensorMassFunctionMask.sortedPowerset = None
        TensorMassFunctionMask.setMap = None
        TensorMassFunctionMask.setMapChar2Int = {}
        TensorMassFunctionMask.setMapInt2Char = {}
        TensorMassFunctionMask.projectionMask = None
        mydict = {k:0.0 for k in frame}
        tmp = TensorMassFunctionMask(mydict)
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
        if TensorMassFunctionMask.sortedPowerset != None:
            return TensorMassFunctionMask.sortedPowerset
        time_start = time.time()
        sortFrame = self.GetSortedFrame()
        n = len(sortFrame)
        result = []
        for i in range(0, 2**n):
            combo = self.list_of_ones(i)
            comboChar = frozenset([sortFrame[k] for k in combo])
            combo = frozenset(combo)
            result.append(combo)
            TensorMassFunctionMask.setMapChar2Int[comboChar] = combo
            TensorMassFunctionMask.setMapInt2Char[combo] = comboChar
        
        TensorMassFunctionMask.sortedPowerset = result
        TensorMassFunctionMask.setMap = {result[i]:i for i in range(len(result))    }
        time_generate_projection_matrix = time.time()
        #self.GenerateProjectionMask()
        self.time_init = time.time() - time_start
        self.time_generate_projection_matrix = time.time() - time_generate_projection_matrix
        return  result
    
    def ConvertMassFuntionToVector(self):
        if self.vec is not None: return self.vec
        sortedPowerset = self.GetSortedPowerset()
        n = len(sortedPowerset)
        V = np.zeros((n))
        for k,v in self.items():
            k_int = TensorMassFunctionMask.setMapChar2Int[k]
            index = TensorMassFunctionMask.setMap[k_int]
            V[index] = v
        self.vec = V
        return V
    def AssignVector(self,V):
        self.vec = V
    
   

    def Combine(self,other):
        t1 = time.time()
        other:TensorMassFunctionMask = other
        v1 = self.ConvertMassFuntionToVector()
        v2 = other.ConvertMassFuntionToVector()
        t2 = time.time(); print('t2t1: ', t2-t1)


        m2 = np.outer(v1,v2)


        m3 = np.zeros((len(m2)))
        n = m2.shape[0]
        t3 = time.time(); print('t3t2: ', t3-t2)

        for i in range(n):
            for j in range(n):
                m3[i&j] += m2[i,j]


        t4 = time.time(); print('t4t3: ', t4-t3)

        m3[0] =0 
        m3 = m3/np.sum(m3)
        t5 = time.time(); print('t5t3: ', t5-t4)

        return TensorMassFunctionMask(m3)

    def ConvertToOriginalMassFunction(self):
        sortedPowerset = self.GetSortedPowerset()
        for i in range(len(self.vec)):
            v = self.vec[i] 
            if v == 0: continue
            k = TensorMassFunctionMask.setMapInt2Char[sortedPowerset[i]]
            self[k] = v
        return self
    def bel(self, hypothesis=None):
        if hypothesis is None:
            return {h:self.bel(h) for h in  TensorMassFunctionMask.setMapChar2Int.keys()}
        else:
            k_int = TensorMassFunctionMask.setMapChar2Int[frozenset(hypothesis)]
            index = TensorMassFunctionMask.setMap[k_int]
            val = 0
            for i in range(1,len(self.vec)):
                if i&index == i:
                    val += self.vec[i]
            return val
        
        
    def pl(self, hypothesis=None):
        if hypothesis is None:
            return {h:self.pl(h) for h in  TensorMassFunctionMask.setMapChar2Int.keys()}
        else:
            k_int = TensorMassFunctionMask.setMapChar2Int[frozenset(hypothesis)]
            index = TensorMassFunctionMask.setMap[k_int]
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
    TensorMassFunctionMask.SetFrame(['a','b','c'])

    tm1 = TensorMassFunctionMask({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) # using a dictionary

    tm2 = TensorMassFunctionMask({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) # using a dictionar
    elements = ['a', 'b', 'c', 'd']
    
    m12 = tm1.Combine(tm2)
    
    m12.ConvertToOriginalMassFunction()
    print(m12)

    print(m12.pl())
    print(m12.bel())
    print(m12.pignistic())
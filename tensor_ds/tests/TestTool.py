import numpy as np
import time

def list_of_ones(n):
        result = []
        position = 0
        while n > 0:
            if n & 1:
                result.append(position)
            n >>= 1
            position += 1
        return result
def GenerateFullFrameOfDiscernment(n):
    sortFrame = [chr(ord('a') + i) for i in range(n)]
    asd=123
    result  = []
    resultChar = []
    for i in range(0, 2**n):
        combo = list_of_ones(i)
        comboChar = frozenset([sortFrame[k] for k in combo])
        combo = frozenset(combo)
        result.append(combo)
        resultChar.append(comboChar)
    m = 2**n
    array = np.random.rand(m)
    array[0] = 0 
    array = array/sum(array)
    dicts = {   }
    for i in range(len(array)):
        dicts[resultChar[i]] = array[i]
    return sortFrame,dicts,array

def GenerateSingularrameOfDiscernment(n):
    sortFrame = [chr(ord('a') + i) for i in range(n)]
    result  = []
    resultChar = []
    for i in range(0, 2**n):
        combo = list_of_ones(i)
        comboChar = frozenset([sortFrame[k] for k in combo])
        combo = frozenset(combo)
        result.append(combo)
        resultChar.append(comboChar)
    m = 2**n
    array = np.random.rand(m)
    for i in range(2**n):
        if len(list_of_ones(i)) != 1:
            array[i] =0

    array = array/sum(array)
    dicts = {   }
    for i in range(len(array)):
        dicts[resultChar[i]] = array[i]
    return sortFrame,dicts,array


if __name__ == '__main__':
    #GenerateFullFrameOfDiscernment(5)
    sortFrame,dicts,array = GenerateSingularrameOfDiscernment(6)
    asd=123

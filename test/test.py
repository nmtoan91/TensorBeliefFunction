from TensorBeliefFunction.tensords import TensorMassFunction
TensorMassFunction.SetFrame(['a','b','c'])
tm1 = TensorMassFunction({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) 
tm2 = TensorMassFunction({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) 
elements = ['a', 'b', 'c', 'd']
m12 = tm1.Combine(tm2)
m12.ConvertToOriginalMassFunction()
print(m12)



from TensorBeliefFunction.tensords_mask import TensorMassFunctionMask
TensorMassFunctionMask.SetFrame(['a','b','c'])
tm1 = TensorMassFunctionMask({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) 
tm2 = TensorMassFunctionMask({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) 
elements = ['a', 'b', 'c', 'd']
m12 = tm1.Combine(tm2)
m12.ConvertToOriginalMassFunction()
print(m12)




from TensorBeliefFunction.tensords_mask_csc import TensorMassFunctionMask_CSC
TensorMassFunctionMask_CSC.SetFrame(['a','b','c'])
tm1 = TensorMassFunctionMask_CSC({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) 
tm2 = TensorMassFunctionMask_CSC({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) 
elements = ['a', 'b', 'c', 'd']
m12 = tm1.Combine(tm2)
m12.ConvertToOriginalMassFunction()
print(m12)



from TensorBeliefFunction.tensords_csc import TensorMassFunction_CSC
TensorMassFunction_CSC.SetFrame(['a','b','c'])
tm1 = TensorMassFunction_CSC({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) 
tm2 = TensorMassFunction_CSC({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) 
elements = ['a', 'b', 'c', 'd']
m12 = tm1.Combine(tm2)
m12.ConvertToOriginalMassFunction()
print(m12)



from TensorBeliefFunction.tensords_csc_wise import TensorMassFunction_CSC_Wise
TensorMassFunction_CSC_Wise.SetFrame(['a','b','c'])
tm1 = TensorMassFunction_CSC_Wise({'a':0.3, 'c':0.2, 'ab':0.2, 'ac':0.3}) 
tm2 = TensorMassFunction_CSC_Wise({'b':0.2, 'c':0.1, 'ab':0.5, 'abc':0.2}) 
elements = ['a', 'b', 'c', 'd']
m12 = tm1.Combine(tm2)
m12.ConvertToOriginalMassFunction()
print(m12)



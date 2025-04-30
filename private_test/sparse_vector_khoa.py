import numpy as np
import scipy.sparse as sp

n = 16
a = {
    'indice': [0,1,2,3,4,8,9,10,13,15],
    'value':  [3,4,5,1,2,3,10,12,3,14]
}

data = np.array(a['value'])
row_indices = np.array(a['indice']) 
col_indices = np.zeros_like(a['indice']) 


A = sp.csc_matrix((data, (row_indices, col_indices)), shape=(n, 1))

odd_data = []; odd_rows = []
even_data = []; even_rows = []

for data_index in range(A.indptr[0], A.indptr[1],2):
    even_index = A.indices[data_index ]
    odd_index = A.indices[data_index+ 1]
    even_value = A.data[data_index ]
    odd_value = A.data[data_index+1]
    if odd_value != 0:
        odd_data.append(odd_value)
        odd_rows.append(odd_index)
    if even_value != 0:
        even_data.append(even_value)
        even_rows.append(even_index)

   
even_vec = sp.csc_matrix((even_data, (even_rows, [0]*len(even_rows))), shape=(n, 1))
#print(even_vec.data)
odd_vec = sp.csc_matrix((odd_data, (odd_rows, [0]*len(odd_rows))), shape=(n, 1))
#print(odd_vec.data)


print(even_vec+odd_vec)
print(even_vec-odd_vec)
    
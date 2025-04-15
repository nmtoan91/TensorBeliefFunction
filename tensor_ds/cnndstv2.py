import torch
import torch.nn as nn
import numpy as np

   
class subtraction_module(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1,-1]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0,1]]],dtype='float32')), requires_grad=False)

    def forward(self, value_list):
        res = []
        for x, name in value_list:
            g0 = self.q0_conv(x)
            g1 = self.q1_conv(x)
            
            res.append((g0, '0'+ name))
            res.append((g1, '1'+ name))

        return res
    

class h_2_module(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1,1]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0,1]]],dtype='float32')), requires_grad=False)

    def forward(self, x_list):
        res = []
        for m, name in x_list:
            g0 = self.q0_conv(m)
            g1 = self.q1_conv(m)
            
            res.append((g0, '0'+ name))
            res.append((g1, '1'+ name))
        return res


class CNNDSTv2(torch.nn.Module):
    def __init__(self,N):
        super().__init__()
        self.N = N
        self.len = 2**N
        self.h_2_module = h_2_module()
        self.subtraction_module = subtraction_module()

    def forward(self, m12):
        m = [(m12, '')]
        for _ in range(self.N):
            m = self.h_2_module.forward(m)

        m.sort(key=lambda x: x[1])
        
        _value_m = [ _m[0]*_m[1] for _m,_ in m ]
        _value_m = torch.stack(_value_m)

        subtract = [(torch.Tensor(_value_m).reshape(1,1,-1),'')]
        for _ in range(self.N):
            subtract = self.subtraction_module.forward(subtract)
        subtract.sort(key=lambda x: x[1])
        subtract = torch.stack([x[0] for x in subtract])
        subtract = subtract.permute(3,0,2,1)

        return subtract

    def post_process_m(self, m):
        return m.view(m.shape[:2])
    
    def warmup(self):
        m1 = np.random.rand(2**self.N)
        m2 = np.random.rand(2**self.N)
        m1[0] = 0
        m2[0] = 0
        m1 = m1/m1.sum()
        m2 = m2/m2.sum()
        m12 = torch.tensor(np.array([[m1],[m2]], dtype='float32'))
        
        m12 = m12.to(next(self.parameters()).device)     
        with torch.no_grad():
            _ = self.forward(m12)


class subtraction_module_optimized(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1,-1]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(1,1, 2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0,1]]],dtype='float32')), requires_grad=False)

    def forward(self, value_list):
        x = torch.cat([m for m, _ in value_list], dim=0)
        g0 = self.q0_conv(x)
        g1 = self.q1_conv(x)
        
        res = []
        for idx in range(len(value_list)):  # Loop over batch size to append to results
            res.append((g0[idx:idx+1], '0'+value_list[idx][1]))
            res.append((g1[idx:idx+1], '1'+value_list[idx][1]))
        return res
    

class h_2_module_optimized(torch.nn.Module):
    def __init__(self):
        super().__init__()
        
        # Fixed weights for the convolutions
        self.q0_conv = nn.Conv1d(2, 2, 2, groups=2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1, 1]], [[1, 1]]], dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(2, 2, 2, groups=2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0, 1]], [[0, 1]]], dtype='float32')), requires_grad=False)

    def forward(self, x_list):
        # Concatenate all the tensors in the batch
        x = torch.cat([m for m, _ in x_list], dim=0)  # Shape (batch_sz, 2, 2**N)
        g0 = self.q0_conv(x)
        g1 = self.q1_conv(x)
        
        res = []
        for idx in range(len(x_list)):  # Loop over batch size to append to results
            res.append((g0[idx:idx+1], '0'+x_list[idx][1]))
            res.append((g1[idx:idx+1], '1'+x_list[idx][1]))
        return res


class CNNDSTv2_optimized(torch.nn.Module):
    def __init__(self,N):
        super().__init__()
        self.N = N
        self.len = 2**N
        self.h_2_module = h_2_module_optimized()
        self.subtraction_module = subtraction_module_optimized()
        # self.subtraction_module = subtraction_module()

    def forward(self, m12):
        m = [(m12, '')]
        for _ in range(self.N):
            m = self.h_2_module.forward(m)

        m.sort(key=lambda x: x[1])
        
        _value_m = [ _m[:,0,:]*_m[:,1,:] for _m,_ in m ]
        _value_m = torch.stack(_value_m)

        subtract = [(torch.Tensor(_value_m).reshape(1,1,-1),'')]
        for _ in range(self.N):
            subtract = self.subtraction_module.forward(subtract)
        subtract.sort(key=lambda x: x[1])
        subtract = torch.stack([x[0] for x in subtract])
        subtract = subtract.permute(3,0,2,1)

        return subtract

    def post_process_m(self, m):
        return m.view(m.shape[:2])
    
    def warmup(self):
        m1 = np.random.rand(2**self.N)
        m2 = np.random.rand(2**self.N)
        m1[0] = 0
        m2[0] = 0
        m1 = m1/m1.sum()
        m2 = m2/m2.sum()
        m12 = torch.tensor(np.array([[m1,m2]], dtype='float32'))
        
        m12 = m12.to(next(self.parameters()).device)     
        with torch.no_grad():
            _ = self.forward(m12)
    
    



# class h_2_module_batch(torch.nn.Module):
#     def __init__(self):
#         super().__init__()
#         self.q0_conv = nn.Conv1d(2,2, 2,groups=2, stride=2, bias=False)
#         self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1,1]],[[1,1]]],dtype='float32')), requires_grad=False)

#         self.q1_conv = nn.Conv1d(2,2, 2,groups=2, stride=2, bias=False)
#         self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0,1]],[[0,1]]],dtype='float32')), requires_grad=False)

#     def forward(self, x_list):
#         res = []
#         for m, name in x_list:
#             g0 = self.q0_conv(m)
#             g1 = self.q1_conv(m)
            
#             res.append((g0, '0'+ name))
#             res.append((g1, '1'+ name))
#         return res

class subtraction_module_batch(nn.Module):
    def __init__(self):
        super().__init__()
        
        # Define fixed weights for the convolutions
        self.q0_conv = nn.Conv1d(1, 1, 2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1, -1]]], dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(1, 1, 2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0, 1]]], dtype='float32')), requires_grad=False)

    def forward(self, value_list):
        # Concatenate the inputs in the batch dimension
        x = torch.cat([v[0] for v in value_list], dim=0)  # Shape: (batch_sz, 1, 2**N)

        # Apply the convolutions on the entire batch
        g0 = self.q0_conv(x)  # Shape: (batch_sz, 1, len)
        g1 = self.q1_conv(x)  # Shape: (batch_sz, 1, len)

        # Collect results in the format (output, name)
        res = []
        for idx in range(len(value_list)):
            res.append((g0[idx:idx+1], '0' + value_list[idx][1]))
            res.append((g1[idx:idx+1], '1' + value_list[idx][1]))

        return res
    
class h_2_module_batch(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv1d(2, 2, 2, groups=2, stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[1,1]],[[1,1]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv1d(2, 2, 2, groups=2, stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[0,1]],[[0,1]]],dtype='float32')), requires_grad=False)

    def forward(self, x_list):
        # Concatenate all the tensors in the batch
        x = torch.cat([m for m, _ in x_list], dim=0)  # Shape (batch_sz, 2, 2**N)
        g0 = self.q0_conv(x)
        g1 = self.q1_conv(x)
        
        res = []
        for idx in range(len(x_list)):  # Loop over batch size to append to results
            res.append((g0[idx:idx+1], '0'+x_list[idx][1]))
            res.append((g1[idx:idx+1], '1'+x_list[idx][1]))
        return res
    

class CNNDSTv2_batch(torch.nn.Module):
    def __init__(self,N):
        super().__init__()
        self.N = N
        self.len = 2**N
        self.h_2_module_batch = h_2_module_batch()
        self.subtraction_module = subtraction_module_batch()

    def forward(self, M):
        """
        input_params:
        M: shape of (batch_sz, 2,2**N)
        """
        m = [(M, '')]
        for _ in range(self.N):
            m = self.h_2_module_batch.forward(m)

        m.sort(key=lambda x: x[1])
        
        _value_m = [ _m[:,0,:]*_m[:,1,:] for _m,_ in m ]
        _value_m = torch.stack(_value_m)
        _value_m = _value_m.permute(1,2,0)

        subtract = [(torch.Tensor(_value_m).reshape(1,1,-1),'')]
        for _ in range(self.N):
            subtract = self.subtraction_module.forward(subtract)
        subtract.sort(key=lambda x: x[1])
        subtract = torch.stack([x[0] for x in subtract])

        subtract = subtract.permute(3,0,2,1)

        return subtract

    def post_process_m(self, m):
        return m.view(m.shape[:2])
    
    def warmup(self):
        m1 = np.random.rand(2**self.N)
        m2 = np.random.rand(2**self.N)
        m1[0] = 0
        m2[0] = 0
        m1 = m1/m1.sum()
        m2 = m2/m2.sum()
        m3 = np.random.rand(2**self.N)
        m4 = np.random.rand(2**self.N)
        m3[0] = 0
        m4[0] = 0
        m3 = m3/m3.sum()
        m4 = m4/m4.sum()
        # m1234 = torch.tensor(np.array([[m1,m2],[m3,m4]], dtype='float32'))
        m1234 = torch.tensor(np.array([[m1,m2]], dtype='float32'))
        
        m1234 = m1234.to(next(self.parameters()).device)     
        with torch.no_grad():
            _ = self.forward(m1234)


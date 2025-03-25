import torch
import torch.nn as nn
import numpy as np

   
class h_module(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv2d(1,1, (2,2), stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[[1,1],[1,0]]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv2d(1,1, (2,2), stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[[0,0],[0,1]]]],dtype='float32')), requires_grad=False)

    def forward(self, x_list):
        res = []
        for x, name in x_list:
            g0 = self.q0_conv(x)
            g1 = self.q1_conv(x)
            
            res.append((g0, '0'+ name))
            res.append((g1, '1'+ name))

        return res
    
class CNNDST(torch.nn.Module):
    def __init__(self,N):
        super().__init__()
        self.N = N
        self.h_module = h_module()

    def forward(self, M):
        m = [(M, '')]
        for _ in range(self.N):
            m = self.h_module.forward(m)

        m.sort(key=lambda x: x[1])

        m = torch.stack([_m for _m,_ in m])
        m = m.permute(1,0,2,3,4)

        return m

    def post_process_m(self, m):
        return m.view(m.shape[:2])
    
    def warmup(self):
        m1 = np.random.rand(2**self.N)
        m2 = np.random.rand(2**self.N)
        m1[0] = 0
        m2[0] = 0
        m1 = m1/m1.sum()
        m2 = m2/m2.sum()
        M = np.matmul(np.array([m1]).transpose(),np.array([m2]))
        M = np.array([[M]], dtype='float32')
        M = torch.tensor(M)
        # print('Is in GPU: ',next(self.parameters()).is_cuda)
        
        M = M.to(next(self.parameters()).device)     
        with torch.no_grad():
            _ = self.forward(M)

class h_module_optimized(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.q0_conv = nn.Conv2d(1,1, (2,2), stride=2, bias=False)
        self.q0_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[[1,1],[1,0]]]],dtype='float32')), requires_grad=False)

        self.q1_conv = nn.Conv2d(1,1, (2,2), stride=2, bias=False)
        self.q1_conv.weight = torch.nn.Parameter(torch.tensor(np.array([[[[0,0],[0,1]]]],dtype='float32')), requires_grad=False)

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
    
    
class CNNDST_optimized(torch.nn.Module):
    def __init__(self,N):
        super().__init__()
        self.N = N
        self.h_module = h_module_optimized()

    def forward(self, M):
        m = [(M, '')]
        for _ in range(self.N):
            m = self.h_module.forward(m)

        m.sort(key=lambda x: x[1])

        m = torch.stack([_m for _m,_ in m])
        m = m.permute(1,0,2,3,4)

        return m

    def post_process_m(self, m):
        return m.view(m.shape[:2])
    
    def warmup(self):
        m1 = np.random.rand(2**self.N)
        m2 = np.random.rand(2**self.N)
        m1[0] = 0
        m2[0] = 0
        m1 = m1/m1.sum()
        m2 = m2/m2.sum()
        M = np.matmul(np.array([m1]).transpose(),np.array([m2]))
        M = np.array([[M]], dtype='float32')
        M = torch.tensor(M)
        
        
        M = M.to(next(self.parameters()).device)     
        with torch.no_grad():
            _ = self.forward(M)
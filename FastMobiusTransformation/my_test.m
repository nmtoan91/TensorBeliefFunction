//matlab -batch "my_test"
tic;
m1=[0 0.4 0.1 0.2 0.2 0 0 0.1]';
m2=[0 0.2 0.3 0.1 0.1 0 0.2 0.1]';

M_comb_PCR6=DST([m1 m2],8);

toc;

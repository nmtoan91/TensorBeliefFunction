function var_vec=chooseaseq(varbelstruct, invar_vec)
% CHOOSEASEQ selects a deletion sequence from a set of var to be deleted
%   the algorithm is simple: variables are sorted by number of beliefs involved
%   the variable present in the smallest number of beliefs is deleted first
% VARBELSTRUCT: var-bel struct (5 fields .varnums; .varcard; .belnums; .belcard; .cross)
% INVAR_VEC: a vector of variables

invar_vec=intersect(invar_vec, varbelstruct.varnums);   % take intersection of set of vars and vars to delete
var_indx=extfind(invar_vec, varbelstruct.varnums);      % take indices

lenvar=length(invar_vec);

tmp_mat=zeros(lenvar, 2);               % 2 columns
tmp_mat(:,1)=invar_vec';                % 1st column contains bel numbers

tmp_varbel=varbelstruct.cross(var_indx, :);
involve_vec=sum(tmp_varbel, 2);
tmp_mat(:,2)=involve_vec;

tmp_mat=sortrows(tmp_mat, 2);
var_vec=tmp_mat(:,1)';
%%%%%%%%%%%%%%%% end of CHOOSEASEQ
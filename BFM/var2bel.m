function belinvolved=var2bel(varbelstruct, var_list)
%VAR2BEL  gives the list of belief id_numners in VARBELSTRUCT that include a variable in VAR_LIST in its domain
%           
% VARBELSTRUCT structure containing infor about varbel relationship. It has 5 fields
%   VARBELSTRUCT.VARNUMS list of variable id_numbers
%   VARBELSTRUCT.VARCARD list of variable cardinalities
%   VARBELSTRUCT.BELNUMS list of belief id_numbers
%   VARBELSTRUCT.BELCARD list of belief cardinalities
%   VARBELSTRUCT.CROSS  table of cross reference
%
% VAR_LIST: the list of variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varv_indx=extfind(var_list, varbelstruct.varnums);
varv_indx=varv_indx(find(varv_indx));               % remove 0 index from varv_indx

if isempty(varv_indx)
    error('The variables in the list are not defined.')
end

tmp_varbelcross=varbelstruct.cross(varv_indx,:);    % select rows related to the variables
if length(varv_indx)==1
    incidence_vec=tmp_varbelcross;
else
    incidence_vec=max(tmp_varbelcross);
end
belinvolved=varbelstruct.belnums(find(incidence_vec));
%%%%%%%%%%%%%%% end of VAR2BEL
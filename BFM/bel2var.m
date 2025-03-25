function varinvolved=bel2var(varbelstruct, bel_list)
%BEL2VAR gives the list of variables that are included in the domains of bels in bel_list
% VARBELSTRUCT structure containing infor about varbel relationship. It has 5 fields
%   VARBELSTRUCT.VARNUMS list of variable id_numbers
%   VARBELSTRUCT.VARCARD list of variable cardinalities
%   VARBELSTRUCT.BELNUMS list of belief id_numbers
%   VARBELSTRUCT.BELCARD list of belief cardinalities
%   VARBELSTRUCT.CROSS  table of cross reference
% BEL_LIST: the list of variable

belv_indx=extfind(bel_list, varbelstruct.belnums);
belv_indx=belv_indx(find(belv_indx));               % remove 0 index from varv_indx

if isempty(belv_indx)
    error('The beliefs in the list are not defined.')
end

tmp_varbelcross=varbelstruct.cross(:, belv_indx);    % select rows related to the variables
if length(belv_indx)==1
    incidence_vec=tmp_varbelcross;
else
    incidence_vec=max(tmp_varbelcross,[],2);
end
varinvolved=varbelstruct.varnums(find(incidence_vec));
%%%%%%%%%%%%%%% end of BEL2VAR
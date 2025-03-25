function varbelstruct=removeavar(invarbelstruct, vartoremove)
%REMOVEAVAR    removes a variable in from pool of variables to be processed
% INVARBELSTRUCT   variable-belief structure 
%   INVARBELSTRUCT.VARNUMS: a vector of variable id_numbers
%   INVARBELSTRUCT.VARCARD: a vector of variable cardinalities
%   INVARBELSTRUCT.BELNUMS: a vector of belief id_numbers
%   INVARBELSTRUCT.BELCARD: a vector of belief cardinalities (# of foset)
%   INVARBELSTRUCT.CROSS: a 2D matrix of 0s and 1s of size nvars*nbels
% VARTOREMOVE   the variable to be removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global BELIEF;                                      % VARIABLE MOFI ATTRIBUTE STRUCTURE FRAME;

beltocombine=var2bel(invarbelstruct, vartoremove);              % take id of beliefs to be combined

combinedbel=multcombine(beltocombine);

allbelnums=[BELIEF(:).number];

bel_indx=find(allbelnums==combinedbel);

currbel=BELIEF(bel_indx);
currdomain=currbel.domain_variable;
currbelnum=currbel.number;
prj_domain=setdiff(currdomain, vartoremove);
if isempty(prj_domain)
	invarbelstruct=belremove(invarbelstruct, beltocombine);
else
	newbelnum=bproject(currbelnum, prj_domain);   % project on domain with a variable removed
	invarbelstruct=belremove(invarbelstruct, beltocombine);
	invarbelstruct=beladd(invarbelstruct, newbelnum);
end

var_indx=find(invarbelstruct.varnums==vartoremove);
invarbelstruct.varnums(var_indx)=[];
invarbelstruct.varcard(var_indx)=[];
invarbelstruct.cross(var_indx,:)=[];
varbelstruct=invarbelstruct;
%%%%%%%%%%%%%%% end of REMOVEAVAR
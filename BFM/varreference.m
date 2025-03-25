function varnumcard=varreference(var_list)
%VARREFERENCE creates a reference structure for variables in VAR_LIST
% VARNUMCARD is a stucture of 2 fields
% VARNUMCARD.NUMS: the sorted list of variables
% VARNUMCARD.CARD: the list of corresponding cardinality
%%%%%%%%%%%%%%%%%%%%%%

global VARIABLE FRAME;              % BELIEF MOFI ATTRIBUTE STRUCTURE 

allvarnums=[VARIABLE(:).number];    % collect the id_numbers of variables
k=length(allvarnums);
allvarcard=zeros(1, k);             % fill cardinality
for i=1:k
    nframe = VARIABLE(i).frame;
    indx_frame=find([FRAME(:).number]==nframe);
    if isempty(indx_frame)
        error('A frame used for a variable is not defined.')
    end
    if FRAME(indx_frame).type==1    % integer interval type
        allvarcard(i)=FRAME(indx_frame).max - FRAME(indx_frame).min + 1;
    else
        allvarcard(i)=FRAME(indx_frame).cardinality;
    end
end
var_list=sort(var_list);
tmp_indx=extfind(var_list, allvarnums);
if ~isempty(find(tmp_indx==0))
    error('A variable in the list is not defined.')
else
    varnumcard.nums=var_list;
    varnumcard.card=allvarcard(tmp_indx);
end
%%%%%%%%%%%%%%%%%% end of VARREFERENCE
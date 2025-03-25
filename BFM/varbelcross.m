function varbelstruct=varbelcross(belief_list)
%VARBELCROSS summarises the relationship between variables and belief potentials contained in the beliefs_list 
% BELIEF_LIST:  list of relevant beliefs
% VARBELSTRUCT has 5 fields
%   VARBELSTRUCT.VARNUMS: a vector of variable id_numbers
%   VARBELSTRUCT.VARCARD: a vector of variable cardinalities
%   VARBELSTRUCT.BELNUMS: a vector of belief id_numbers
%   VARBELSTRUCT.BELCARD: a vector of belief cardinalities (# of foset)
%   VARBELSTRUCT.CROSS: a 2D matrix of 0s and 1s of size nvars*nbels
%       NVARS: is the number of variables
%       NBELS: is the number of beliefs
%   VARBELSTRUCT.CROSS(i,j)=1: VARNUMS(i) is present in the domain of BELNUMS(j)

global BELIEF VARIABLE;     % MOFI ATTRIBUTE STRUCTURE FRAME;

if nargin==0                % in the default case all beliefs in the database are included
	belnumbers=[BELIEF(:).number];
else
    belnumbers= belief_list;
end
allvarnumbers=[VARIABLE(:).number];
allbelnumbers=[BELIEF(:).number];

belindx_vec=extfind(belnumbers,allbelnumbers);
belindx_vec=belindx_vec(find(belindx_vec));     % remove bel id_number not defined

belnumbers=allbelnumbers(belindx_vec);

nofvars=length(allvarnumbers);
nofbels=length(belnumbers);

belsizes=zeros(1, nofbels);      % initiate a vector for belief cardinality (# of fosets)
varbeltable=zeros(nofvars, nofbels);

for j=1:nofbels
    bel_indx=find(allbelnumbers==belnumbers(j));
    belsizes(j)=length(BELIEF(bel_indx).bp(1).form(1).values);   % mass vector
    
    acolumn=zeros(nofvars, 1);
    bel_domain=BELIEF(bel_indx).domain_variable;
    indx_vec=extfind(bel_domain, allvarnumbers);
    acolumn(indx_vec)=1;
    varbeltable(:,j)=acolumn;
end

varref=varreference(allvarnumbers);
allvarsizes=varref.card;            % a vector containing cardinalities of variables

relevantvector=max(varbeltable,[],2);   % take maximum by rows
var_indx=find(relevantvector==0);       % index of variables not involved in beliefs
if ~isempty(var_indx)
	allvarnumbers(var_indx)=[];             % remove irrelevant vars from var-numbers vector
	allvarsizes(var_indx)=[];               % from var-size vector
	varbeltable(var_indx, :)=[];            % from var-bel table
end

tmp_mat=cat(2, allvarnumbers', allvarsizes', varbeltable);
tmp_mat=sortrows(tmp_mat,1);        % sort the table by var id_numbers
allvarnumbers=tmp_mat(:,1)';        % sorted list of var id_numbers
allvarsizes=tmp_mat(:,2)';          % list of cardinalities
tmp_mat(:,[1 2])=[];                % remove var column

tmp_mat=cat(1, belnumbers, belsizes, tmp_mat); % add the first row of bel id_numbers, 2nd for bel sizes
tmp_mat=(sortrows(tmp_mat', 1))';
belnumbers=tmp_mat(1,:);         % sorted list of beliefs
belsizes=tmp_mat(2,:);
tmp_mat([1 2],:)=[];

varbelstruct.varnums=allvarnumbers;
varbelstruct.varcard=allvarsizes;
varbelstruct.belnums=belnumbers;
varbelstruct.belcard=belsizes;
varbelstruct.cross=tmp_mat;
%%%%%%%%%%%%%%%% end of VARBELCROSS
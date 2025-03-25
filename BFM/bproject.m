function bel_id2=bproject(bel_id1, prj_domain)
%BPROJECT projects a belief potentials in m form on the PRJ_DOMAIN
% by Phan Giang
% start date: April 20, 2002
% bel_id2 is the number of project belief
% bel_id1 is the number of to be projected belief
% prj_domain is the list of variables - project domain
% last update: Nov 22, 2002
%%%%%%%%%%%%%%%%%%%%%%
global BELIEF;              % VARIABLE MOFI ATTRIBUTE STRUCTURE FRAME

beliefcounter=max([BELIEF(:).number]);         % use for next newly created  belief number

%check the validity of bel_id1
if ~ismember(bel_id1, [BELIEF(:).number])
    error('The input belief number is invalid.')
end

bel_indx1=extfind(bel_id1, [BELIEF(:).number]);    % find the index of belief from the idenfication number 
first_bel = BELIEF(bel_indx1);
domain1=first_bel.domain_variable;                   % domains of belief potentials
varref = varreference(union(domain1, prj_domain));

if ~isempty(first_bel.conditioning_variable)
    warning('One potential seems to be in conditional form. It is assumed to be unconditional.')
end
word_size=50;

bel1_foset=first_bel.bp(1).form(1).focal_sets;  % take the focal sets from belief info
bel1_value=first_bel.bp(1).form(1).values;      % mass values
[num1_foset, num1_word]=size(bel1_foset);       % number of focal sets and number of words

% check the project domain
tmp_vec=extfind(prj_domain, varref.nums);
if ~isempty(find(tmp_vec==0))
    warning('A variable in the project domain is not defined.')
    prj_domain=intersect(prj_domain, varref.nums);
    tmp_vec=extfind(prj_domain, varref.nums);
end
card_prj=varref.card(tmp_vec);              % contains cardinalities of vars in prj_domain


tmp_vec=extfind(domain1, [varref.nums]);    % take indices of variable in the domain
if ~isempty(find(tmp_vec==0))
    error('A variable in domain 1 is not defined.')
end

card1=varref.card(tmp_vec);                 % contains cardinalities of vars in the domain
pframe1_size=prod(card1);                   % size of product frame 1

if mod(pframe1_size,word_size)==0           % if frame size is multiple of word_size
    lastw1_size=word_size;                  % calculation of # bit in the last word of address
    nword1=pframe1_size/word_size;
else
    lastw1_size=mod(pframe1_size, word_size);  % size of the last word
    nword1=ceil(pframe1_size/word_size);
end

if ~(num1_word==nword1)
    fprintf('num1_word=%d nword1=%d', num1_word, nword1)
    error('Frame size and foset address are not consistent.')
end

domain_inter =intersect(domain1, prj_domain);       % intersection of domains
domain_rmve = setdiff(domain1, prj_domain);         % domain1-prj_domain
domain_irvn = setdiff(prj_domain, domain1);         % irrelevant part of prj_domain

card_inter=card1(extfind(domain_inter, domain1));   % cardinality of projected bel
card_rmve=card1(extfind(domain_rmve, domain1));     % cardinality of var to be removed

inter_frmsize=prod(card_inter);                     % frame size for projected bel
rmv_frmsize=prod(card_rmve);

len_inter=length(domain_inter);                     % length of the projected domain
len_rmve=length(domain_rmve);                   
len_irvn=length(domain_irvn);

% handle situation when one of the sets is empty.
if isempty(domain_inter)        % project on an empty domain.
    error('Project on an empty domain.')
elseif isempty(domain_rmve)     % nothing to remove, project = original
    bel_id2 = bel_id1;
    return
end

% extract integer matrix into bit vectors, word_size bits for each word except the last one
bitv1_foset=int2bitv(bel1_foset, pframe1_size); % bit vector address for belief1

% convert bit vector into coordinate system in which each varable represents one dimension
crdn1_foset=reshape(bitv1_foset',[card1 num1_foset]);
k1=length(size(crdn1_foset));   % length of the size vector=number of dims which equals
                                % # variables if (num_foset==1), # vars+1 otherwise

perm1=extfind([domain_inter domain_rmve], domain1); % permutation vector on bel 
                                                    % such that variables in intersection constitute the first segment
                                                    % variables to be removed constitute the secon segment
                                                   
if num1_foset==1        % there are two cases: (1) the number of foset is 1; (2) more than 1
    crdn1_foset=permute(crdn1_foset, perm1);
    card_vector=[card_inter rmv_frmsize];
    k=length(card_vector);      % position of to be removed dim, in this case the last one
else
    crdn1_foset=permute(crdn1_foset, [perm1 length(card1)+1]);  % length(card)+1 = # of dim corr to the # of fosets
    card_vector=[card_inter rmv_frmsize num1_foset];
    k=length(card_vector)-1;    % position of to be removed dim, in this case one before the last
end

crdn1_foset=reshape(crdn1_foset, card_vector);
prj_foset=max(crdn1_foset, [], k);      % take max on k-th dim; prj_foset contains ASCII codes
prj_foset=reshape(prj_foset, [inter_frmsize, num1_foset]);
prj_foset=char(prj_foset');             % converts into char format '1' and '0'

% integer matrices for focal sets after projection
intmat1_foset=bitmat2intmat(prj_foset, word_size);
[nfoset1, ncolumn]=size(intmat1_foset);

[nroffoset, nrofmassvec] = size(bel1_value);
tmp_mat=cat(2, intmat1_foset, bel1_value);
[tmpnrows, tmpncols] = size(tmp_mat);
tmp_mat=collapsemat(tmp_mat, tmpncols-nrofmassvec+1:tmpncols);

[nrows, ncols]=size(tmp_mat);               % size of tmp_mat after collapsing
tmp_mat=sortrows(tmp_mat, ncols-nrofmassvec+1:-1:1);    % sort focal sets by their masses
tmp_mat=tmp_mat(nrows:-1:1, :);             % to have masses in descending order

% create the projected belief
bel_indx2=length(BELIEF)+1;                   % new index for new belief
bel_id2=beliefcounter+1;

BELIEF(bel_indx2).number = bel_id2; 	% id_number is generated by belcounter
BELIEF(bel_indx2).disposable = 1;		% 1 = may be erased (clear) , 0 = [] = must be kept (default)
BELIEF(bel_indx2).agent = 'You';		% who is the belief holder
BELIEF(bel_indx2).time = 1;				% at what epoch
BELIEF(bel_indx2).ec = [];	            % ec = evidential corpus, on what bel is based, blabla	
BELIEF(bel_indx2).domain_variable = domain_inter;
BELIEF(bel_indx2).domain_cardinality = varref.card(extfind(domain_inter, varref.nums));
BELIEF(bel_indx2).conditioning_variable = [];
BELIEF(bel_indx2).bp(1).form(1).type = 'm'; 
BELIEF(bel_indx2).bp(1).form(1).ordered = 1; % 1 = ordered by masses
BELIEF(bel_indx2).bp(1).form(1).focal_sets = tmp_mat(:, 1:ncols-nrofmassvec);
BELIEF(bel_indx2).bp(1).form(1).values = tmp_mat(:, ncols-nrofmassvec+1:ncols);   % masses given

birthrecord(1, bel_id1, bel_id2);       % creates a record in BELTRACE

%%%%%%%%%%%%%%%% end of BPROJECT
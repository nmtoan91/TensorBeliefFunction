function bel_id3=bcombine(bel_id1, bel_id2)
%BCOMBINE joins two belief potentials in m form.
% by Phan Giang
% start date: April 06, 2002
% bel_id3 is the combination of bel_id1 and bel_id2
% bel_id3, bel_id1 and bel_id2 are id_numbers of belief potentials
% Last update: 05/09/2003
%%%%%%%%%%%%%%%%%%%%%%
global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME NORMAL APPRO;

beliefcounter=max([BELIEF(:).number]);         % use for newly created next belief number

%check the validity of bel_id1 and bel_id2
if ~(ismember(bel_id1, [BELIEF(:).number]) & ismember(bel_id2, [BELIEF(:).number]))
    error('The input belief numbers are invalid.')
end

bel_indx1=find(bel_id1==[BELIEF(:).number]);
bel_indx2=find(bel_id2==[BELIEF(:).number]);
first_bel = BELIEF(bel_indx1);
secon_bel = BELIEF(bel_indx2);

if ~(isempty(first_bel.conditioning_variable) & isempty(secon_bel.conditioning_variable))
    warning('One potential seems to be in conditional form. It is assumed to be unconditional.')
end
word_size=50;

bel1_foset=first_bel.bp(1).form(1).focal_sets;  % take the focal sets from belief info
bel2_foset=secon_bel.bp(1).form(1).focal_sets;
bel1_value=first_bel.bp(1).form(1).values;      % mass values
bel2_value=secon_bel.bp(1).form(1).values;

[num1_foset, num1_word]=size(bel1_foset);     % number of focal sets and number of words
[num2_foset, num2_word]=size(bel2_foset);

domain1=first_bel.domain_variable;                   % domains of belief potentials
domain2=secon_bel.domain_variable;                   % domains of belief potentials
varref = varreference(union(domain1, domain2));

tmp_vec1=extfind(domain1, [varref.nums]); % take indices of variable in the domain
if ~isempty(find(tmp_vec1==0))
    error('One variable in domain 1 is not defined.')
else
    card1=varref.card(tmp_vec1);             % contains cardinalities of vars in the domain
end

tmp_vec2=extfind(domain2, [varref.nums]);      % take indices of variable in the domain
if ~isempty(find(tmp_vec2==0))
    error('One variable in domain 2 is not defined.')
else
    card2=varref.card(tmp_vec2);             % contains cardinalities of vars in the domain
end

pframe1_size=prod(card1);                   % size of product frame 1
pframe2_size=prod(card2);                   % size of product frame 2

if mod(pframe1_size,word_size)==0      % if frame size is multiple of word_size
    lastw1_size=word_size;             % calculation of # bit in the last word of address
    nword1=pframe1_size/word_size;
else
    lastw1_size=mod(pframe1_size, word_size);  % size of the last word
    nword1=ceil(pframe1_size/word_size);
end

if mod(pframe2_size,word_size)==0
    lastw2_size=word_size;                 % calculation of # bit in the last word of address
    nword2=pframe2_size/word_size;
else
    lastw2_size=mod(pframe1_size, word_size);
    nword2=ceil(pframe2_size/word_size);
end

if ~(num1_word==nword1)
    fprintf('num1_word=%d, nword1=%d', num1_word, nword1)
    error('Frame size and foset address are not consistent.')
elseif ~(num2_word==nword2)
    fprintf('num2_word=%d, nword2=%d', num2_word, nword2)
    error('Frame size and foset address are not consistent.')
end

domain_inter=intersect(domain1, domain2);       % intersection of domains
domain_1less2 = setdiff(domain1, domain2);      % domain1-domain2
domain_2less1 = setdiff(domain2, domain1);
len_inter=length(domain_inter);                 % take lengths
len_1less2=length(domain_1less2);
len_2less1=length(domain_2less1);

% handle situation when any of them is empty.
% a permutation for each domains such that variables in intersection constitute 
% the first segment, variables proper to the domain constitute the secon segment

% extract integers into bit vectors, word_size bits for each word except the last one
bitv1_foset=int2bitv(bel1_foset, pframe1_size); % bit vector address for belief1
bitv2_foset=int2bitv(bel2_foset, pframe2_size); % bit vector address for belief2

% convert bit vector into coordinate system in which each varable represents one dimension
if num1_foset > 1
    crdn1_foset=reshape(bitv1_foset',[card1 num1_foset]);
elseif length(card1)==1
    crdn1_foset=bitv1_foset';
else
    crdn1_foset=reshape(bitv1_foset',card1);
end

if num2_foset > 1
	crdn2_foset=reshape(bitv2_foset',[card2 num2_foset]);
elseif length(card2)==1
	crdn2_foset=bitv2_foset';
else
	crdn2_foset=reshape(bitv2_foset',card2);
end

k1=length(size(crdn1_foset));   % length of the size vector=number of dims which equals
k2=length(size(crdn2_foset));   % # variables if (num_foset==1), # vars+1 otherwise

if isempty(domain_inter)        % two domains do not intersect
    perm1=[];
    perm2=[];
	ext1_foset=squeeze(repmat(crdn1_foset, [ones(1, k1) card2]));
	if num1_foset > 1
        pervec1=[1:k1-1 k1+[1:length(card2)] k1];  % so that the last dim denotes # fosets
        ext1_foset=permute(ext1_foset, pervec1);
	end
	
	ext2_foset=squeeze(repmat(crdn2_foset, [ones(1, k2) card1]));
	% permute so that the order of variable in ext2 is the same as on ext1
	if num2_foset==1
        pervec2=[len_2less1+[1:len_1less2] [1:len_2less1]];
	else
        pervec2=[len_2less1+1+[1:len_1less2] [1:len_2less1+1]];
	end

    ext2_foset=permute(ext2_foset, pervec2);
	domain_union=[domain1 domain2];     % order of vars in union is the extension of first bel
	union_card=varref.card(extfind(domain_union, varref.nums));
	unionframe_size=prod(union_card);                           % size of union frame

else    % domain_inter <> 0 -- two domains intersect
	if (~isempty(domain_1less2) & ~isempty(domain_2less1))      % non empty (dom1-dom2) and (dom2-dom1)
        perm1=extfind([domain_inter domain_1less2], domain1);
        perm2=extfind([domain_inter domain_2less1], domain2);
		% change the order of variables in the bel potentials so that the common vars appear first
		% and then the variables specific for each potential.
		% there are two cases: (1) the number of foset is 1; (2) more than 1
		if num1_foset==1
            crdn1_foset=permute(crdn1_foset, perm1);
		else
            crdn1_foset=permute(crdn1_foset, [perm1 length(card1)+1]);  % length(card)+1 = # of dim corr to the # of fosets
		end
		
		if num2_foset==1
            crdn2_foset=permute(crdn2_foset, perm2);
		else
            crdn2_foset=permute(crdn2_foset, [perm2 length(card2)+1]);
		end
	
        % cardinalities of variables in dom1-dom2 and dom2-dom1
		% this information is used for extension of domains to the union of domains
		card1_2 = card1(extfind(domain_1less2, domain1));
		card2_1 = card2(extfind(domain_2less1, domain2));
		
		ext1_foset=squeeze(repmat(crdn1_foset, [ones(1, k1) card2_1]));
		if num1_foset > 1
            pervec1=[1:k1-1 k1+[1:length(card2_1)] k1];  % so that the last dim denotes # fosets
            ext1_foset=permute(ext1_foset, pervec1);
		end
		
		ext2_foset=squeeze(repmat(crdn2_foset, [ones(1, k2) card1_2]));
		% permute so that the order of variable in ext2 is the same as on ext1
		if num2_foset==1
            pervec2=[1:len_inter len_inter+len_2less1+[1:len_1less2] len_inter+[1:len_2less1]];
		else
            pervec2=[1:len_inter len_inter+len_2less1+1+[1:len_1less2] len_inter+[1:len_2less1+1]];
		end
		ext2_foset=permute(ext2_foset, pervec2);
        domain_union=[domain_inter domain_1less2 domain_2less1];     % order of vars in union is the extension of first bel
		union_card=varref.card(extfind(domain_union, varref.nums));
		unionframe_size=prod(union_card);                           % size of union frame
        
	elseif (isempty(domain_1less2) & ~isempty(domain_2less1))    % domain1 is a proper subset of domain2
        perm1=[];
        perm2=extfind([domain1 domain_2less1], domain2);
        
		if num2_foset==1
            crdn2_foset=permute(crdn2_foset, perm2);
		else
            crdn2_foset=permute(crdn2_foset, [perm2 length(card2)+1]);
		end
		ext2_foset=crdn2_foset;         % bel2 does not need extension
	
        % cardinalities of variables in dom1-dom2 and dom2-dom1
		% this information is used for extension of domains to the union of domains
		card1_2 = [];
		card2_1 = card2(extfind(domain_2less1, domain2));
		
		ext1_foset=squeeze(repmat(crdn1_foset, [ones(1, k1) card2_1]));
		if num1_foset > 1
            pervec1=[1:k1-1 k1+[1:length(card2_1)] k1];  % so that the last dim denotes # fosets
            ext1_foset=permute(ext1_foset, pervec1);
		end
        domain_union=[domain1 domain_2less1];     % order of vars in union is the extension of first bel
		union_card=varref.card(extfind(domain_union, varref.nums));
		unionframe_size=prod(union_card);                           % size of union frame
        
	elseif (~isempty(domain_1less2) & isempty(domain_2less1))     % domain2 is a proper subset of domain1
        perm2=[];
        perm1=extfind([domain2 domain_1less2], domain1);
		if num1_foset==1
            crdn1_foset=permute(crdn1_foset, perm1);
		else
            crdn1_foset=permute(crdn1_foset, [perm1 length(card1)+1]);  % length(card)+1 = # of dim corr to the # of fosets
		end
		ext1_foset=crdn1_foset;         % bel1 does not need extension
	
        % cardinalities of variables in dom1-dom2 and dom2-dom1
		% this information is used for extension of domains to the union of domains
		card2_1 = [];
		card1_2 = card1(extfind(domain_1less2, domain1));
		
		ext2_foset=squeeze(repmat(crdn2_foset, [ones(1, k2) card1_2]));
		if num2_foset > 1
            pervec2=[1:k2-1 k2+[1:length(card1_2)] k2];  % so that the last dim denotes # fosets
            ext2_foset=permute(ext2_foset, pervec2);
		end
        domain_union=[domain2 domain_1less2];     % order of vars in union is the extension of first bel
		union_card=varref.card(extfind(domain_union, varref.nums));
		unionframe_size=prod(union_card);                           % size of union frame
        
    elseif (isempty(domain_1less2) & isempty(domain_2less1))    % two domains have the same variables (may be diff order)
        ext1_foset=crdn1_foset;
        if isequal(domain1, domain2)       % 2 domains are exactly equal
            ext2_foset=crdn2_foset;
        else
            perm2=extfind(domain1,domain2);
            if num2_foset==1
                ext2_foset=permute(crdn2_foset, perm2);
            else
                ext2_foset=permute(crdn2_foset, [perm2 length(card2)+1]);
            end
        end
        domain_union= domain1;     % order of vars in union is the extension of first bel
		union_card=varref.card(extfind(domain_union, varref.nums));
		unionframe_size=prod(union_card);                           % size of union frame
    else
        warning('There is unforseen situation');
        return
	end
end

% convert coordinated extensions into matrices of bitvectors
ext1_foset=reshape(ext1_foset, [unionframe_size, num1_foset])';
ext2_foset=reshape(ext2_foset, [unionframe_size, num2_foset])';

% integer matrices for focal sets after extension
intmat1_foset=bitmat2intmat(ext1_foset, word_size);
intmat2_foset=bitmat2intmat(ext2_foset, word_size);

[nfoset1, ncolumn]=size(intmat1_foset);
[nfoset2, ncolumn]=size(intmat2_foset);    % two matrices have the same # of columns

% to take pointwise bitand of focal sets
comp1=squeeze(repmat(intmat1_foset, [1 nfoset2]))';  % replicate by horizontal dir
comp1=reshape(comp1, [ncolumn, nfoset1*nfoset2])';

comp2=squeeze(repmat(intmat2_foset, [nfoset1 1]));
intersection_foset=bitand(comp1, comp2);
% intersection_foset=reshape(intersection_foset, [ncolumn nfoset1*nfoset2])';

% calculation of masses
[nrfosetone, nrmassvone] = size(bel1_value);
[nrfosettwo, nrmassvtwo] = size(bel2_value);
nrfosetcomb = nrfosetone*nrfosettwo;    % number of focal sets in combined bel (before collapsing)
nrmassvcomb = nrmassvone*nrmassvtwo;    % number of mass vectors

fin_value = [];
for i=1:nrmassvone
    for j=1:nrmassvtwo
        valvecone = bel1_value(:,i);
        valvectwo = bel2_value(:,j);
        valveccom = valvectwo*valvecone';   % this order is VERY important
        fin_value = cat(2, fin_value, valveccom(:));
    end
end
% fin_value = reshape(fin_value, [nrfosetcomb nrmassvcomb]);                                        

% sort to purge identical focal sets; adding a number of columns that contains mass value
tmp_mat=cat(2, intersection_foset, fin_value);
[nrows, ncols]=size(tmp_mat);               % before updating
tmp_mat=collapsemat(tmp_mat,ncols-nrmassvcomb+1:ncols);
[nrows, ncols]=size(tmp_mat);               % take size after collapsing

tmp_mat=sortrows(tmp_mat, [ncols-nrmassvcomb+1:-1:1]);    % sort focal sets by their masses
tmp_mat=tmp_mat(nrows:-1:1, :);             % to have masses in descending order

% create the combination belief
bel_indx=length(BELIEF)+1;                   % new index for new belief
bel_id3=beliefcounter+1;

BELIEF(bel_indx).number = bel_id3; 		% id_number is generated by belcounter
BELIEF(bel_indx).disposable = 1;		% 1 = may be erased (clear) , 0 = [] = must be kept (default)
BELIEF(bel_indx).agent = 'You';		    % who is the belief holder
BELIEF(bel_indx).time = 1;				% at what epoch
BELIEF(bel_indx).ec = [];	            % ec = evidential corpus, on what bel is based, blabla	
BELIEF(bel_indx).domain_variable = domain_union;
BELIEF(bel_indx).domain_cardinality = union_card;
BELIEF(bel_indx).conditioning_variable = [];
BELIEF(bel_indx).bp(1).form(1).type = 'm'; 
BELIEF(bel_indx).bp(1).form(1).representation = 'selected';
BELIEF(bel_indx).bp(1).form(1).focal_sets = tmp_mat(:, 1:ncols-nrmassvcomb);
BELIEF(bel_indx).bp(1).form(1).values = tmp_mat(:,ncols-nrmassvcomb+1:ncols);   % masses given

birthrecord(2, [bel_id1, bel_id2], bel_id3);        % creates a record in BELTRACE

if NORMAL == 1
    tmp_belid = normalize(bel_id3);
    birthrecord(10, bel_id3, tmp_belid);        % code 10 for normalization
    bel_id3 = tmp_belid;
end

if APPRO ~= 0
    if APPRO == 1
        tmp_belid = approx(bel_id3);
    else
        tmp_belid = approx(bel_id3, APPRO);
    end
    birthrecord(11, bel_id3, tmp_belid);        % code 11 for approximation
    bel_id3 = tmp_belid;
end
% save testdata BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME;

%%%%%%%%%%%%%%%% end of BCOMBINE
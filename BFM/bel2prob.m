function resultbel = bel2prob(bellist)
% BEL2PROB transforms mass values into probability. 2 transformations are
% used. Pignistic and plausibilistic.
% Input: bellist the list of belief id number
% Output: resultbel
% Last update: 05/06/2003

global BELIEF;              % VARIABLE MOFI ATTRIBUTE STRUCTURE FRAME

resultbel = [];
nrofbels = length(bellist)
for belcounter = 1:nrofbels
    currbelid = bellist(belcounter);
	%check the validity of bel_id1
	if ~ismember(currbelid, [BELIEF(:).number])
        fprintf('The input belief number is invalid %d.\n', currbelid);
        continue
	end
	
	currbel_indx=extfind(currbelid, [BELIEF(:).number]);    % find the index of belief from the idenfication number 
	first_bel = BELIEF(currbel_indx);
	domain1=first_bel.domain_variable;                   % domains of belief potentials
	varref = varreference(domain1);
	
	if ~isempty(first_bel.conditioning_variable)
        warning('One potential seems to be in conditional form. It is assumed to be unconditional.')
	end
	
	word_size=50;
	
	bel1_foset=first_bel.bp(1).form(1).focal_sets;  % take the focal sets from belief info
	massvalue=first_bel.bp(1).form(1).values;      % mass values
	[num1_foset, num1_word]=size(bel1_foset);       % number of focal sets and number of words
	
	tmp_vec=extfind(domain1, [varref.nums]);        % take indices of variable in the domain
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
	
	% extract integer matrix into bit vectors, word_size bits for each word except the last one
	
	char01foset=int2bitv(bel1_foset, pframe1_size); % bit vector address for belief1
	[nrows ncols] = size(char01foset);
	masspignis = massvalue;            % copy mass to vector for pignistic 
	for i=1:nrows
        thisrow = char01foset(i,:);
        nofones = length(find(thisrow=='1'));
        if nofones > 0
            masspignis(i) = masspignis(i)/nofones;
        else
            masspignis(i) = 0;
        end
	end
	
	unionrow = repmat('0', [1 ncols]);          % take union row
	pignistiprob = zeros(1, ncols);             % for pignistic prob
	plausibiprob = zeros(1, ncols);             % for plausibility prob
	
	for j=1:ncols
        thiscolumn = char01foset(:, j);
        ones_indx = find(thiscolumn=='1');
        if ~isempty(ones_indx)
            unionrow(j) = '1';
            pignistiprob(j) = sum(masspignis(ones_indx));
            plausibiprob(j) = sum(massvalue(ones_indx));     
        end
	end
	
	onesindxunion = find(unionrow=='1');
	nrofsingelem = length(onesindxunion);
	
	charprobelem = repmat('0', [nrofsingelem, ncols]);
	for i=1:nrofsingelem
        charprobelem(i, onesindxunion(i)) = '1';
	end
	pignistiprob(pignistiprob==0) = [];         % remove zero elem
	plausibiprob(plausibiprob==0) = [];         % in row form
	pignconst = sum(pignistiprob);
	plauconst = sum(plausibiprob);
	pignistiprob = pignistiprob./pignconst;
	plausibiprob = plausibiprob./plauconst;
	
	intprobmatelem = bitmat2intmat(charprobelem, word_size);
	
	tmp_pignistic = cat(2, intprobmatelem, pignistiprob');
	tmp_plausibil = cat(2, intprobmatelem, plausibiprob');
	[nrowpign ncolpign] = size(tmp_pignistic);
	[nrowplau ncolplau] = size(tmp_plausibil);
	tmp_pignistic = sortrows(tmp_pignistic, [ncolpign:-1:1]);
	tmp_plausibil = sortrows(tmp_plausibil, [ncolplau:-1:1]);
	
	BELIEF(currbel_indx).bp(1).form(2).type = 'pignistic probability'; 
	BELIEF(currbel_indx).bp(1).form(2).ordered = 1;            % 1 = ordered by masses
	BELIEF(currbel_indx).bp(1).form(2).focal_sets = tmp_pignistic(nrowpign:-1:1,1:ncolpign-1);
	BELIEF(currbel_indx).bp(1).form(2).values = tmp_pignistic(nrowpign:-1:1, ncolpign);   % masses given
	
	BELIEF(currbel_indx).bp(1).form(3).type = 'plausibilistic probability';
	BELIEF(currbel_indx).bp(1).form(3).ordered = 1;            % 1 = ordered by masses
	BELIEF(currbel_indx).bp(1).form(3).focal_sets = tmp_plausibil(nrowplau:-1:1,1:ncolplau-1);
	BELIEF(currbel_indx).bp(1).form(3).values = tmp_plausibil(nrowplau:-1:1, ncolplau);   % masses given
    resultbel = [resultbel currbelid];
end
%%%%%%%%%%%%%%%% end of BEL2PROB
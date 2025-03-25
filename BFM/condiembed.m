function belidlist = condiembed(inbelidlist)
% CONDIEMBED converts a conditional belief into unconditional belief using
% conditional embedding (Smets rule)
% Input
%   inbelidlist - list of id numbers for input (conditional) beliefs
% Output: belidlist - the list of new id numbers for unconditional beliefs

global BELIEF VARIABLE FRAME;

inbelindxlist = extfind(inbelidlist, [BELIEF(:).number]);

if ~isempty(find(inbelindxlist==0))                 % invalid inbelid
    fprintf('Invalid input: belief id number: %d.\n', inbelidlist(find(inbelindxlist==0)));
    inbelindxlist = inbelindxlist(find(inbelindxlist));     % remove invalid bels from input list
    inbelidlist = inbelidlist(find(inbelindxlist));
    return;
end

nrbels = length(inbelindxlist);
belidlist = zeros(1, nrbels);

for k = 1:nrbels
    inbelnr = inbelidlist(k);
    inbelindx = inbelindxlist(k);
	if isempty(BELIEF(inbelindx).conditioning_variable)     % check for conditioning
        fprintf('Input belief %d is not a conditional belief.\n', inbelnr);
        belidlist(k) = inbelnr;
        continue
	end
	
	% determine frame sizes: frameone for conditioned (A) frametwo for conditioning (B) in A|B expression
	domainA = BELIEF(inbelindx).domain_variable;                      % list of variable in A
	domainB = BELIEF(inbelindx).conditioning_variable.var_num;        % list of conditioning variables
	lendomA = length(domainA);
	lendomB = length(domainB);
	if ~isempty(intersect(domainA, domainB))
        error('Invalid domains A and B: intersection is not empty.');
	end
	embededdomain = [domainA, domainB];     % domain for embeded belief
	
	condinstance = BELIEF(inbelindx).conditioning_variable.instance;     % list of elem id numbers in the instance
	if length(condinstance) ~= lendomB
        error('Inconsistency: conditioning domain and instance are of different lengths.');
	end
	
	cardvecA = zeros(1,lendomA);
	cardvecB = zeros(1,lendomB);
	for i=1:lendomA
        thisvarnum = domainA(i);
        thisvarindx = extfind(thisvarnum, [VARIABLE(:).number]);
        if thisvarindx == 0
            error('Invalid variable id number.');
        end
        thisframenum = VARIABLE(thisvarindx).frame;
        thisframeindx = extfind(thisframenum, [FRAME(:).number]);
        if thisframeindx == 0
            error('Invalid frame id number.');
        end
        cardvecA(i) = FRAME(thisframeindx).cardinality;
	end
	
	for i=1:lendomB
        thisvarnum = domainB(i);
        thisvarindx = extfind(thisvarnum, [VARIABLE(:).number]);
        if thisvarindx == 0
            error('Invalid variable id number.');
        end
        thisframenum = VARIABLE(thisvarindx).frame;
        thisframeindx = extfind(thisframenum, [FRAME(:).number]);
        if thisframeindx == 0
            error('Invalid frame id number.');
        end
        cardvecB(i) = FRAME(thisframeindx).cardinality;
	end
	
	cumulsizeA = cumprod(cardvecA);   % cumulative dim size
	cumulsizeB = cumprod(cardvecB);
	framesizeA = cumulsizeA(lendomA);
	framesizeB = cumulsizeB(lendomB);
	
	if lendomB == 1
        serialinstance = condinstance;      % serial number of the instance in the frame B
	else
        serialinstance = condinstance(1);
        for j=2:lendomB
            serialinstance = serialinstance + (condinstance(j)-1)*cumulsizeB(j-1);
        end
	end
	
	infoset_intv = BELIEF(inbelindx).bp(1).form(1).focal_sets;  % focal set in integer matrix form
	inmass = BELIEF(inbelindx).bp(1).form(1).values;
	nroffoset = length(inmass);                                 % number of focal sets
	
	inbitvmat=int2bitv(infoset_intv, framesizeA);               % convert into bit vector 
	
	tmpembvmat = repmat('0', [nroffoset, framesizeA*framesizeB]);  % to contain embedded bit vectors
	complementA = bitstrinverse(inbitvmat);
	offset = (serialinstance-1)*framesizeA;
	
	tmpembvmat(:, offset+1:offset+framesizeA) = complementA;
	embedbitvmat = bitstrinverse(tmpembvmat);
	
	newintmat = bitmat2intmat(embedbitvmat); 
	
	tmp_mat = cat(2, newintmat, inmass);        % for sorting by mass and also by focal sets
	[nrows, ncols] = size(tmp_mat);
	tmp_mat = sortrows(tmp_mat, [ncols:-1:1]);
	tmp_mat = tmp_mat(nrows:-1:1,:);
	
	newbelindx = length([BELIEF(:).number])+1;
	newbelidnum = max([BELIEF(:).number])+1;
	
	vfullname = cat(2, 'emb', BELIEF(inbelindx).full_name);
	if length(vfullname) < 5
        vshortname = vfullname;
	else
        vshortname = vfullname(1:5);
	end
	
	BELIEF(newbelindx).number = newbelidnum;
	BELIEF(newbelindx).full_name = vfullname;
	BELIEF(newbelindx).short_name = vshortname;
	BELIEF(newbelindx).disposable = 0;
	BELIEF(newbelindx).agent = 'You';		  
	BELIEF(newbelindx).time = 1;			
	BELIEF(newbelindx).ec = [];
	BELIEF(newbelindx).domain_variable = embededdomain;
	BELIEF(newbelindx).domain_cardinality = length(embededdomain);
	BELIEF(newbelindx).conditioning_variable = [];
	BELIEF(newbelindx).bp(1).form(1).type = 'm'; 
	BELIEF(newbelindx).bp(1).form(1).ordered = 1;                           % 1 = ordered by masses
	BELIEF(newbelindx).bp(1).form(1).focal_sets = tmp_mat(:, 1:ncols-1);    % for 4 focal sets address in bin form
	BELIEF(newbelindx).bp(1).form(1).values = tmp_mat(:, ncols);                   % masses given
	
	belidlist(k) = newbelidnum;
	birthrecord(4, inbelnr, newbelidnum);               % creates a record in BELTRACE
end
%%%%% end of CONDIEMBED
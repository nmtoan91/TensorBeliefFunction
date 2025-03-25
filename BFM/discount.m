function belidlist = discount(inbelidlist, discountvec)
% DISCOUNT discounts beliefs by a rate
% 
% Input
%   inbelidlist - list of id numbers for input beliefs
%   discountvec - vector of rates to which discount is made
% Output: belidlist - the list of new id numbers for beliefs
% Last update: 05/08/2003

global BELIEF VARIABLE FRAME;

inbelindxlist = extfind(inbelidlist, [BELIEF(:).number]);

if ~isempty(find(inbelindxlist==0))                 % invalid inbelid
    fprintf('Invalid input: belief id number: %d.\n', inbelidlist(find(inbelindxlist==0)));
    inbelindxlist = inbelindxlist(find(inbelindxlist));     % remove invalid bels from input list
    inbelidlist = inbelidlist(find(inbelindxlist));
    if length(discountvec) == length(inbelidlist)
        discountvec = discountvec(find(inbelindxlist))
    end
end

if isempty(inbelidlist)
    return
end

nrbels = length(inbelindxlist);
belidlist = zeros(1, nrbels);

if length(discountvec) == 1
    discountvec = repmat(discountvec, [nrbels, 1]);
elseif length(discountvec) ~= nrbels
    fprintf('Number of rates are not consistent with the number of beliefs.\n');
    discountvec = repmat(discountvec(1), [nrbels, 1]);
end

for k = 1:nrbels
    discountrate = discountvec(k);
    inbelnr = inbelidlist(k);
    inbelindx = inbelindxlist(k);
	
	% determine frame size
	domain = BELIEF(inbelindx).domain_variable;                 % list of variable in the domain
	lendom = length(domain);
	cardvec = zeros(1,lendom);          % cardinality vector
	for i=1:lendom
        thisvarnum = domain(i);
        thisvarindx = extfind(thisvarnum, [VARIABLE(:).number]);
        if thisvarindx == 0
            error('Invalid variable id number.');
        end
        thisframenum = VARIABLE(thisvarindx).frame;
        thisframeindx = extfind(thisframenum, [FRAME(:).number]);
        if thisframeindx == 0
            error('Invalid frame id number.');
        end
        cardvec(i) = FRAME(thisframeindx).cardinality;
	end
	
	framesize = prod(cardvec);          % size of frame 
	tautologybitvec = repmat('1', [1, framesize]);
    tautologyintvec = bitmat2intmat(tautologybitvec);   % integer vector form of tautology
    
	infoset_intv = BELIEF(inbelindx).bp(1).form(1).focal_sets;  % focal set in integer matrix form
	inmass = BELIEF(inbelindx).bp(1).form(1).values;
	nroffoset = length(inmass);                                 % number of focal sets
    tautoexists = 0;
    tautopositi = 0;
	for i = 1:nroffoset
        thisrow = infoset_intv(i,:);
        if isequal(thisrow, tautologyintvec)
            tautoexists = 1;
            tautopositi = i;
            break
        end
    end
	if tautoexists == 1         % there is already a tautology among the focal sets
        inmass = inmass.*(1-discountrate);
        inmass(tautopositi) = inmass(tautopositi) + discountrate;
    else                        % add a tautology to the focal sets
        infoset_intv = cat(1, infoset_intv, tautologyintvec);
        inmass = inmass.*(1-discountrate);
        inmass = cat(1, inmass, discountrate);
    end
    
	tmp_mat = cat(2, infoset_intv, inmass);        % for sorting by mass and also by focal sets
	[nrows, ncols] = size(tmp_mat);
	tmp_mat = sortrows(tmp_mat, [ncols:-1:1]);
	tmp_mat = tmp_mat(nrows:-1:1,:);
	
	newbelindx = length([BELIEF(:).number])+1;
	newbelidnum = max([BELIEF(:).number])+1;
	
	vfullname = cat(2, 'disc', BELIEF(inbelindx).full_name);
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
	BELIEF(newbelindx).domain_variable = BELIEF(inbelindx).domain_variable;
	BELIEF(newbelindx).domain_cardinality = BELIEF(inbelindx).domain_cardinality;
	BELIEF(newbelindx).conditioning_variable = BELIEF(inbelindx).conditioning_variable;
	BELIEF(newbelindx).bp(1).form(1).type = 'm'; 
	BELIEF(newbelindx).bp(1).form(1).ordered = 1;                           % 1 = ordered by masses
	BELIEF(newbelindx).bp(1).form(1).focal_sets = tmp_mat(:, 1:ncols-1);    % for 4 focal sets address in bin form
	BELIEF(newbelindx).bp(1).form(1).values = tmp_mat(:, ncols);                   % masses given
	
	belidlist(k) = newbelidnum;
	birthrecord(5, inbelnr, newbelidnum);               % creates a record in BELTRACE: 5 code for discounting
end
%%%%% end of DISCOUNT
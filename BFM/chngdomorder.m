function belid = chngdomorder(inbelid, varorder)
% CHNGDOMORDER changes the order of variables in the domain of a belief
% Input
%   inbelid - a belief number
%   varorder - vector of variables
% Output: belid - new belid number

global BELIEF VARIABLE FRAME;

if nargin == 1
    belid = inbelid;
    return
end

inbelindx = extfind(inbelid, [BELIEF(:).number]);
if inbelindx==0             % invalid inbelid
    fprintf('Invalid input: belief id number.\n');
    belid = 0;
    return;
end

indomain = BELIEF(inbelindx).domain_variable;
infoset_intv = BELIEF(inbelindx).bp(1).form(1).focal_sets;
inmass = BELIEF(inbelindx).bp(1).form(1).values;
nrofvars = length(indomain);
nroffoset = length(inmass);

sdiff1 = setdiff(indomain,varorder);        % check if two set are equal
sdiff2 = setdiff(varorder,indomain);
if ~isempty(sdiff1) | ~isempty(sdiff2)
    fprintf('The sets of var in bel and in specified order are different.\n');
    belid = inbelid;
    return;
elseif isequal(indomain,varorder);      % nothing to do when orders are the same
    belid = inbelid;
    return;
end

invarindx = extfind(indomain,[VARIABLE(:).number]);
cardvec = zeros(1, nrofvars);
for i=1:nrofvars            % take cardinality
    thisvarindx = invarindx(i);
    thisframe = VARIABLE(thisvarindx).frame;
    thisframeindx = extfind(thisframe, [FRAME(:).number]);
    cardvec(i) = FRAME(thisframeindx).cardinality;
end

framesize = prod(cardvec);      % take frame size
inbitvmat=int2bitv(infoset_intv, framesize);    % convert into bit vector 
if nroffoset == 1       % one focal set
    inpointmat = reshape(inbitvmat', cardvec);
else                    % more than 1 focal set
    inpointmat = reshape(inbitvmat', [cardvec nroffoset]);
end

permutvec = extfind(varorder,indomain);
newpointmat = permute(inpointmat, [permutvec nrofvars+1]);

newbitvmat = reshape(newpointmat, [framesize nroffoset])';
newintmat = bitmat2intmat(newbitvmat); 

tmp_mat = cat(2, newintmat, inmass);        % for sorting by mass and also by focal sets
[nrows, ncols] = size(tmp_mat);
tmp_mat = sortrows(tmp_mat, [ncols:-1:1]);
tmp_mat = tmp_mat(nrows:-1:1,:);

newbelindx = length([BELIEF(:).number])+1;
newbelidnum = max([BELIEF(:).number])+1;

BELIEF(newbelindx).number = newbelidnum;
BELIEF(newbelindx).full_name = [];
BELIEF(newbelindx).short_name = [];
BELIEF(newbelindx).disposable = 1;
BELIEF(newbelindx).agent = 'You';		  
BELIEF(newbelindx).time = 1;			
BELIEF(newbelindx).ec = [];
BELIEF(newbelindx).domain_variable = varorder;
BELIEF(newbelindx).domain_cardinality = nrofvars;
BELIEF(newbelindx).conditioning_variable = [];
BELIEF(newbelindx).bp(1).form(1).type = 'm'; 
BELIEF(newbelindx).bp(1).form(1).ordered = 1;                           % 1 = ordered by masses
BELIEF(newbelindx).bp(1).form(1).focal_sets = tmp_mat(:, 1:ncols-1);    % for 4 focal sets address in bin form
BELIEF(newbelindx).bp(1).form(1).values = tmp_mat(:, ncols);                   % masses given

belid = newbelidnum;
birthrecord(3, inbelid, belid);             % creates a record in BELTRACE
%%%%% end of CHNGDOMORDER
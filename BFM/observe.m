function belid = observe(varstr, instancestr, newname)
%OBSERVE creates a belief record that corresponds to an observation.
% Input
%   varstr - string of of variable names
%   instancestr - string of observations
% Output: belid - id number for observed belief

global BELIEF VARIABLE FRAME;

if nargin < 2
    error('Not enough input arguments.');
elseif nargin == 2
    newname = [];
end
belid = [];
varcells = readwords(varstr);
inscells = readwords(instancestr);
varlistindx = extstrmatch(varcells, {VARIABLE(:).full_name});       % match names
if ~isempty(find(varlistindx==0))
    fprintf('Variable %s not found.\n', varcells{find(varlistindx==0)});
    return
end

varlistidnum = [VARIABLE(varlistindx).number];                      % extract var idnumbers
nrofvar = length(varlistindx);
instancevec = zeros(1, nrofvar);
framesizevec = zeros(1, nrofvar);
for i=1:nrofvar
    theframe = VARIABLE(varlistindx(i)).frame;
    theframeindx = extfind(theframe, [FRAME(:).number]);
    framesizevec(i) = FRAME(theframeindx).cardinality;
    position = strmatch(inscells{i}, {FRAME(theframeindx).elements}, 'exact');
    if isempty(position)
        fprintf('Value %s not found in the frame of %s.\n', inscells{i}, varcells{i});
        return
    else
        instancevec(i) = position;
	end
end
cumframesize = cumprod(framesizevec);       % cummulative sizes
unionframesize = cumframesize(nrofvar);
if nrofvar == 1
    serialnumber = instancevec;
else
    serialnumber = instancevec(1);
    for j = 2:nrofvar
        serialnumber = serialnumber + (instancevec(j)-1)*cumframesize(j-1);
    end
end

bitvecinst = repmat('0', [1, unionframesize]);
bitvecinst(serialnumber) = '1';
intvecinst = bitmat2intmat(bitvecinst);

newbelindx = length([BELIEF(:).number])+1;
newbelidnum = max([BELIEF(:).number])+1;

vfullname = newname;
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
BELIEF(newbelindx).domain_variable = varlistidnum;
BELIEF(newbelindx).domain_cardinality = length(varlistidnum);
BELIEF(newbelindx).conditioning_variable = [];
BELIEF(newbelindx).bp(1).form(1).type = 'm'; 
BELIEF(newbelindx).bp(1).form(1).ordered = 1;                   % 1 = ordered by masses
BELIEF(newbelindx).bp(1).form(1).focal_sets = intvecinst;       % one focal set
BELIEF(newbelindx).bp(1).form(1).values = 1;                    % mass = 1

belid = newbelidnum;
%%%%%%%%%%%% end of OBSERVE
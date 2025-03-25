function bjtidnum = bjtbuild(avariable, listbels)
% BJTBUILD function constructs binary join tree from BELTRACE that records
% fusion process.
% Input: 
%   a variable marginalization for which provides trace of beliefs that 
%   will be assemblied into a bjtree.
%   list of beliefs from those tree is constructed
% Output: bjtidnum is the id number of a binary join tree

% BJTREE is a structure having following fields
% BJTREE().number           id_number
% BJTREE().full_name        name
% BJTREE().fromquery        number of query from which bjtree is built
% BJTREE().numofnodes       number of nodes
% BJTREE().nodes            list of nodes
% BJTREE().connection       connection matrix
% BJTREE().msgerow_column   messages (belief potentials) go from row to column
% BJTREE().msgecolumn_row   messages go from column to row

% NODE is a structure of following fields
% NODE().number             id_number
% NODE().full_name          name
% NODE().vars               list of variables labeled the node
% NODE().potential          id_number of belief potential attached
% NODE().beltracenum        beltrace number associated with
% NODE().marginal           marginal of join belief function computed

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

if nargin == 1
    userbelindx = ([BELIEF(:).disposable]==0);
    allbelnum = [BELIEF(:).number];
    listbels = allbelnum(userbelindx);
end

if isempty(QUERY)           % there is no query yet
    nmarginal = solve(listbels, avariable);
    thequery = QUERY(1).number;
else    % there is some query 
    nqueries = length(QUERY);
    thequery = 0;
    for i=1:nqueries
        thisqvars = QUERY(i).qvars;
        thisbelbase = QUERY(i).qbelbase;
        if length(thisqvars) == 1
            if (thisqvars == avariable) & isempty(setdiff(listbels,thisbelbase)) & isempty(setdiff(thisbelbase,listbels))
                thequery = QUERY(i).number;
                break
            end
        end
    end

    if thequery == 0
        nmarginal = solve(listbels, avariable);
        thequery = QUERY(end).number;
    end
end

beltracevector = local_traceback(thequery);
nrofbtrace = length(beltracevector);

computedbels = zeros(1, nrofbtrace);
for i = 1:nrofbtrace
    computedbels(i) = BELTRACE([BELTRACE(:).number]==beltracevector(i)).bel_out;
end

inputbels = listbels;               % the list of id number input beliefs

belvector = [inputbels computedbels];
nrofbels = length(belvector);

if isempty(NODE)
    nrnodecount = 0;                % number of nodes
    currentnodeid = 0;              % id number to be signed to next node
else
    nrnodecount = length([NODE(:).number]);
    currentnodeid = max([NODE(:).number]);
end

nodelist = [];
for i=1:nrofbels                    % creation of nodes
    thisbel = belvector(i);
    nrnodecount = nrnodecount + 1;
    currentnodeid = currentnodeid + 1;
    NODE(nrnodecount).number = currentnodeid;       % create a node
    NODE(nrnodecount).full_name = thisbel;          % temp use of belief_id for name of the node
    NODE(nrnodecount).vars = BELIEF([BELIEF(:).number]==thisbel).domain_variable;
    if ismember(thisbel, inputbels)                 % for input bel potential is assigned to node
        NODE(nrnodecount).potential = thisbel;
    else                                            % otherwise potential is empty
        NODE(nrnodecount).potential = [];
    end
    NODE(nrnodecount).marginal = [];
    nodelist = [nodelist currentnodeid];
end

nnodes = nrofbels;

if isempty(BJTREE)
    bjtcounter = 0;                % number of nodes
    bjtidcounter = 0;              % id number to be signed to next node
else
    bjtcounter = length([BJTREE(:).number]);
    bjtidcounter = max([BJTREE(:).number]);
end

connmatrix = zeros(nnodes);             % connection matrix
msgrow_col = zeros(nnodes);             % row-col message matrix 
msgcol_row = zeros(nnodes);             % col_row message matrix 

for i=1:nrofbtrace
    thisbeltrace = beltracevector(i);
    thisbeltrindx = extfind(thisbeltrace, [BELTRACE(:).number]);
    thisaction = BELTRACE(thisbeltrindx).action;
    thisbelout = BELTRACE(thisbeltrindx).bel_out;
    thisbelinvec = BELTRACE(thisbeltrindx).bel_ins;
    
    collumnindx = extfind(thisbelout, belvector);
    rowvecindx = extfind(thisbelinvec, belvector);
    
    if thisaction == 1              % this is projection
        connmatrix(rowvecindx(1),collumnindx) = 1;
        msgrow_col(rowvecindx(1),collumnindx) = thisbelout;
    elseif thisaction == 2          % this is a combination
        connmatrix(rowvecindx(1),collumnindx) = 1;
        msgrow_col(rowvecindx(1),collumnindx) = thisbelinvec(1);
        connmatrix(rowvecindx(2),collumnindx) = 1;
        msgrow_col(rowvecindx(2),collumnindx) = thisbelinvec(2);
    end
end

% remove unnecessary node and link
[row, col, value] = find(msgrow_col);         % check if a message appears twice in messages matrix
tmp_mat = sortrows([row col value], 3);
[nrows, ncols]=size(tmp_mat);

doublication = zeros(nrows,1);
if nrows > 1
    prev_value = tmp_mat(1,3);
    for i=2:nrows
        if tmp_mat(i, 3) == prev_value
            doublication(i-1) = 1;
            doublication(i) = 1;
        end
        prev_value = tmp_mat(i,3);
    end
end

doubindx = find(doublication);

if ~isempty(doubindx)            % there is some message doublication
	doubmat = tmp_mat(doubindx,:);   % copy doublication
    
	toremove = [];
    while ~isempty(doubmat)
        thisvalue = doubmat(1,3);
        thisseriesindx = find(doubmat(:,3)==thisvalue);
        firstrow = doubmat(thisseriesindx(1),1);
        lastcol = doubmat(thisseriesindx(end),2);
        connmatrix(firstrow,lastcol)=1;
        msgrow_col(firstrow,lastcol)=thisvalue;
        toremove = cat(1, toremove, doubmat(1:length(thisseriesindx)-1,2));
        doubmat(thisseriesindx,:)=[];
    end
end

nnodes = nnodes - length(toremove);
nodelist(toremove) = [];

connmatrix(toremove,:)=[];
connmatrix(:,toremove)=[];
msgrow_col(toremove,:)=[];
msgrow_col(:,toremove)=[];
msgcol_row(toremove,:)=[];
msgcol_row(:,toremove)=[];

bjtcounter = bjtcounter + 1;
bjtidcounter = bjtidcounter + 1;
BJTREE(bjtcounter).number = bjtidcounter;
BJTREE(bjtcounter).fromquery = thequery;
BJTREE(bjtcounter).numofnodes = nnodes;
BJTREE(bjtcounter).nodes = nodelist;            % list of nodes
BJTREE(bjtcounter).connection = connmatrix;     % connection matrix
BJTREE(bjtcounter).msgerow_column = msgrow_col; % messages (belief potentials) go from row to column
BJTREE(bjtcounter).msgecolumn_row = msgcol_row; % messages go from column to row

bjtidnum = BJTREE(bjtcounter).number;

return
%%%%%%%%%%%%%%%%% end of bjtbuild

%%%%%%%%%%%%%%%%%%%%
function listbeltrace = local_traceback(querynumber)
% LOCAL_TRACEBACK returns the list of bel traces that describes the
% computation of the query.
% Input: a query number
% Output: a list bel traces

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

listbeltrace = [];

lastbel = QUERY([QUERY(:).number] == querynumber).finalmarg;
beltoresolve = lastbel;         % initial value of the list of belief to trace

while ~isempty(beltoresolve)
    thisbel = beltoresolve(1);
    beltoresolve(1) = [];    
    beltraceindx = extfind(thisbel, [BELTRACE(:).bel_out]); % trace of the belief creation
    if beltraceindx ~= 0
        if ismember(BELTRACE(beltraceindx).action, [1 2])   % combination and projection acts 
            listbeltrace = [BELTRACE(beltraceindx).number listbeltrace];
            beltoresolve = [beltoresolve BELTRACE(beltraceindx).bel_ins];
        end
    end
end
%%%%%%%%%%%%%%%%%%%% end of LOCAL_TRACEBACK
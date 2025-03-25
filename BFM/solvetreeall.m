function beloutlist = solvetreeall(tree)
% SOLVETREELL find marginals for each individual variable based on a tree
% Input
%   binary join tree id number
% Output: is the vector of belief id numbers of required marginals.

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

thetreeindx = extfind(tree, [BJTREE(:).number]);
thenodelist = BJTREE(thetreeindx).nodes;
connmatrix = BJTREE(thetreeindx).connection;
messagerow_col = BJTREE(thetreeindx).msgerow_column;
messagecol_row = BJTREE(thetreeindx).msgecolumn_row;

nrofnodes = length(thenodelist);
nodelabels = cell(1,nrofnodes);         % to store node labels
labelsizes = zeros(1,nrofnodes);        % to store sizes of labels

nodelistindx = extfind(thenodelist,[NODE(:).number]);
for i=1:nrofnodes
    thisnodeindx = nodelistindx(i);
    nodelabels{i} = NODE(thisnodeindx).vars;
    labelsizes(i) = length(nodelabels{i});
end

tmpnode_size = [thenodelist', labelsizes'];
tmpnode_size = sortrows(tmpnode_size, 2);
selectnode = tmpnode_size(nrofnodes,1);
nodetocompute = selectnode;         % select the first node

selectnodeindx = extfind(selectnode,thenodelist);
selectedlabel = nodelabels{selectnodeindx};

todelete = zeros(nrofnodes, 1);
for i=1:nrofnodes
    nodelabels{i} = setdiff(nodelabels{i}, selectedlabel);
    labelsizes(i) = length(nodelabels{i});
    if isempty(nodelabels{i})
        todelete(i) = 1;
    end
end
delindx = find(todelete);
thenodelist(delindx) = [];
nodelabels(delindx) = [];
labelsizes(delindx) = [];

while ~isempty(thenodelist)
    nrofnodes = length(thenodelist);
	tmpnode_size = [thenodelist' labelsizes'];
	tmpnode_size = sortrows(tmpnode_size, 2);
	selectnode = tmpnode_size(nrofnodes,1);
	nodetocompute = [nodetocompute selectnode];         % add the next node
    
	selectnodeindx = extfind(selectnode,thenodelist);    % take the node label
	selectedlabel = nodelabels{selectnodeindx};
	
	todelete = zeros(nrofnodes, 1);
	for i=1:nrofnodes
        nodelabels{i} = setdiff(nodelabels{i}, selectedlabel);
        labelsizes(i) = length(nodelabels{i});
        if isempty(nodelabels{i})
            todelete(i) = 1;
        end
	end
	delindx = find(todelete);
	thenodelist(delindx) = [];
	nodelabels(delindx) = [];
    labelsizes(delindx) = [];
end

nnodetosolve = length(nodetocompute);
listbelcomp = zeros(1,nnodetosolve);
for i=1:nnodetosolve
    thisnode = nodetocompute(i);
    listbelcomp(i) = solvetreenode(tree, thisnode);
end

listbelcompindx = extfind(listbelcomp, [BELIEF(:).number]);
varlistdone = [];
beloutlist = [];
for i=1:nnodetosolve
    thisbel = listbelcomp(i);
    thisbelindx = listbelcompindx(i);
    vartoproj = setdiff(BELIEF(thisbelindx).domain_variable, varlistdone);
    nrofvartoproj = length(vartoproj);
    for j=1:nrofvartoproj
        thisprojbel = bproject(thisbel, vartoproj(j));
        beloutlist = [beloutlist thisprojbel];
    end
    varlistdone = [varlistdone vartoproj];
end
%%% end of SOLVETREALL
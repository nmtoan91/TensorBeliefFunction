function affectedbel = belupdate(tree, oldbel, newbel)
% BELUPDATE updates affected beliefs after one input belief has been
% changed into another belief.
% Input
%   tree - the id number of a tree
%   oldbel - id number of the to be changed belief
%   newbel - id number of the new belief
%   oldbel and newbel must share the same domains (as sets) or otherwise the
%   structure of tree would not be the same.
% Output
%   affectedbel - the list of id numbers of updated beliefs
% Last update: 05/06/2003

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

treeindx = extfind(tree, [BJTREE(:).number]);
treenodelist = BJTREE(treeindx).nodes;
connmatrix = BJTREE(treeindx).connection;
messagematrix = BJTREE(treeindx).msgerow_column + BJTREE(treeindx).msgecolumn_row';   % combine 2 message mats in 1
nnodeintree = length(treenodelist);

oldbelindx = extfind(oldbel, [BELIEF(:).number]);
newbelindx = extfind(newbel, [BELIEF(:).number]);

affectedbel = [];
if (oldbelindx==0 | newbelindx==0)
    fprintf('The beliefs indicated do not exist.\n');
    return
end
domainold = BELIEF(oldbelindx).domain_variable;
domainnew = BELIEF(newbelindx).domain_variable;
if ~isequal(sort(domainold), sort(domainnew))
    fprintf('Updating is not allowed to change variable.\n');
    return
end

nodelistindx = extfind(treenodelist, [NODE(:).number]);
nodetoupdate = treenodelist([NODE(nodelistindx).potential]==oldbel); % find node id to be updated
if length(nodetoupdate) > 1
    nodetoupdate(2:end) = [];       % choose the first one
    warning('The old input belief is present in more than 1 nodes!');
end

clearresult = clearmsge(tree, nodetoupdate);
nodeupdateindx = extfind(nodetoupdate, [NODE(:).number]);
NODE(nodeupdateindx).potential = newbel;        % replace the new bel in node potential

updatemessage = [];
neighborlist = findneighbor(nodetoupdate, tree);
nneighbors = length(neighborlist);
messages = zeros(nneighbors, 2);
for i=1:nneighbors
    messages(i,1) = nodetoupdate;
    messages(i,2) = neighborlist(i);
end
updatemessage = cat(1, updatemessage, messages);

toresolvelist = neighborlist;
resolvedlist = nodetoupdate;
while ~isempty(toresolvelist)
    thisnode = toresolvelist(1);
    thisneighbors = findneighbor(thisnode, tree);
    notresolneigh = setdiff(thisneighbors, resolvedlist);
    if ~isempty(notresolneigh)
    	nneighbors = length(notresolneigh);
		messages = zeros(nneighbors, 2);
		for i=1:nneighbors
            messages(i,1) = thisnode;
            messages(i,2) = notresolneigh(i);
		end
		updatemessage = cat(1, updatemessage, messages);
        toresolvelist = cat(2, toresolvelist, notresolneigh);
    end
    toresolvelist(1) = [];
    resolvedlist = cat(2, resolvedlist, thisnode);
end

[nrows, ncols] = size(updatemessage);
for i=1:nrows
    fromnode = updatemessage(i,1);
    tonode = updatemessage(i,2);
    messagebelid = messagepass(tree, fromnode, tonode);
end
%%% end of BELUPDATE
function beloutid = solvetreenode(tree, finalnode)
%SOLVENODE finds marginal of a node in a binary join tree
% Input
%   tree - the id number of a tree
%   finalnode - the id number of a node for which marginal is sought for
% Output
%   beloutid - the id number of a belief function

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

thetreeindx = extfind(tree, [BJTREE(:).number]);
thenodelist = BJTREE(thetreeindx).nodes;
connmatrix = BJTREE(thetreeindx).connection;
messagerow_col = BJTREE(thetreeindx).msgerow_column;
messagecol_row = BJTREE(thetreeindx).msgecolumn_row;

if isempty(find(thenodelist==finalnode))
    error('The given node does not exist in the given tree.\n');
end

nodelistindx = extfind(thenodelist, [NODE(:).number]);
finalnodeindx = extfind(finalnode, [NODE(:).number]);
if ~isempty(NODE(finalnodeindx).marginal)           % marginal already computed
    beloutid = NODE(finalnodeindx).marginal;
    return
end

nnodes = length(thenodelist);

needmessages = [];
neighborlist = findneighbor(finalnode, tree);
nneighbors = length(neighborlist);
messages = zeros(nneighbors, 2);
for i=1:nneighbors
    messages(i,2) = finalnode;
    messages(i,1) = neighborlist(i);
end
needmessages = cat(1, needmessages, messages);

toresolvelist = neighborlist;
resolvedlist = finalnode;
while ~isempty(toresolvelist)
    thisnode = toresolvelist(1);
    thisneighbors = findneighbor(thisnode, tree);
    notresolneigh = setdiff(thisneighbors, resolvedlist);
    if ~isempty(notresolneigh)
    	nneighbors = length(notresolneigh);
		messages = zeros(nneighbors, 2);
		for i=1:nneighbors
            messages(i,2) = thisnode;
            messages(i,1) = notresolneigh(i);
		end
		needmessages = cat(1, needmessages, messages);
        toresolvelist = cat(2, toresolvelist, notresolneigh);
    end
    toresolvelist(1) = [];
    resolvedlist = cat(2, resolvedlist, thisnode);
end

needmessages = needmessages(end:-1:1, :);       % reverse the order 
[nmessages, ncols] = size(needmessages);

messagematrix = messagerow_col + messagecol_row';   % combine 2 message mats in 1
messagenumber = zeros(nmessages, 1);                % column of belief-message number

% handle each message
for i=1:nmessages
    nodeinrow = needmessages(i,1);
    nodeincol = needmessages(i,2);
    rowindx = extfind(nodeinrow, thenodelist);
    colindx = extfind(nodeincol, thenodelist);
    messagenumber(i) = messagepass(tree, nodeinrow, nodeincol);  % create if necessary message and update BJTREE
end

indxtomessages = find(finalnode==needmessages(:,2)); % indices of in-messages
inmessages = messagenumber(indxtomessages)';

if ~isempty(NODE(finalnodeindx).potential)
    beltocombine = [inmessages NODE(finalnodeindx).potential];
else
    beltocombine = inmessages;
end
beltocombine = beltocombine(find(beltocombine));        % remove 0 from the list
if ~isempty(beltocombine)
    beloutid = multcombine(beltocombine);
else
    beloutid = [];
end
NODE(finalnodeindx).marginal = beloutid;
%%% end of SOLVETREENODE
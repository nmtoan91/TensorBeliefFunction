function neighbors = findneighbor(thenode, thebjtree)
% FINDNEIGHBOR finds the neighbors of a given node in a binary join tree.
% Input:
%   thenode - node id number for which neighborhood is looked for
%   thebjtree - bjtree id number in which neighborhood is searched
% Output: list of node id numbers

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

bjtreeindx = extfind(thebjtree, [BJTREE(:).number]);
if bjtreeindx==0
    error('Invalid bjtree id number.')
end

listofnodes = BJTREE(bjtreeindx).nodes;
connection = BJTREE(bjtreeindx).connection;

theindx = extfind(thenode, listofnodes);
if isempty(find(theindx))
    error('The given node is not in the list.');
end

[nrows, ncols] = size(connection);
if ~(nrows == ncols)
    error('The connection is not a square matrix.');
end    

if ~(nrows == length(listofnodes))
    error('The list of nodes and connection matrix are not compatible.');
end

listindx1 = find(connection(theindx,:));
listindx2 = find(connection(:,theindx)');
neighbors = cat(2, listofnodes(listindx1), listofnodes(listindx2));
%%%%%%%%%%%%% end of FINDNEIGHBOR
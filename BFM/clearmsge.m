function result = clearmsge(tree, startnode)
% CLEARMSGE clear all messages in a tree outgoing from a node
% INPUT 
%   TREE tree number
%   STARTNODE node number
% OUTPUT result = 1 means OK; result = 0 means abnormal

global NODE BJTREE;

result = 1;
treeindx = extfind(tree, [BJTREE(:).number]);
if treeindx == 0
    fprintf('Invalid tree number: %d.\n', tree);
    result = 0;
    return;
end
treenodelist = BJTREE(treeindx).nodes;
nofnodes = length(treenodelist);
treenodeindx = extfind(treenodelist, [NODE(:).number]);

startnodeindx = extfind(startnode, [NODE(:).number]);
if startnodeindx == 0
    fprintf('Invalid node number: %d.\n', startnode);
    result = 0;
    return;
end

if ~ismember(startnode, treenodelist)
    fprintf('Node %d is not present in tree %d.\n', startnode, tree);
    result = 0;
    return
end

for i = 1:nofnodes          % clear all existing marginals computed
    thisnodeindx = treenodeindx(i);
    NODE(thisnodeindx).marginal = [];
end

nodeposintree = extfind(startnode, treenodelist);    % used in manipulation connectmat

connectmat = BJTREE(treeindx).connection;
rowcolmesg = BJTREE(treeindx).msgerow_column;
colrowmesg = BJTREE(treeindx).msgecolumn_row;

doubconnectmat = connectmat + connectmat';  % make direction from row to column

sorted = nodeposintree;
toresolve = nodeposintree;
notsorted = 1:nofnodes;
notsorted(nodeposintree) = [];
while ~isempty(toresolve)
    thispos = toresolve(1);
    thisrow = doubconnectmat(thispos,:);
    onespositions = find(thisrow);
    toadd = setdiff(onespositions, sorted);
    if ~isempty(toadd)
        sorted = [sorted toadd];
        toresolve = [toresolve toadd];
        toaddindx = extfind(toadd, notsorted);
        notsorted(toaddindx) = [];
    end
    toresolve(1) = [];
end

if length(sorted) < nofnodes    % not all nodes are connected (existence isolated subtree)
    toadd = setdiff(1:nofnodes, sorted);
    sorted = [sorted toadd];
end
    
tmp_rowcolmesg = rowcolmesg(sorted, sorted);
tmp_colrowmesg = colrowmesg(sorted, sorted);

refreshmat = tril(ones(nofnodes));          % upper triangle is 0s

newrowcolmesg = tmp_rowcolmesg .* refreshmat;
newcolrowmesg = (tmp_colrowmesg' .* refreshmat)';

recoverorder = extfind(1:nofnodes, sorted);

BJTREE(treeindx).msgerow_column = newrowcolmesg(recoverorder, recoverorder);
BJTREE(treeindx).msgecolumn_row = newcolrowmesg(recoverorder, recoverorder);
%%%%%%% end of CLEARMSGE
function outputbel = csolvetree(tree, updatenode, addedbel, listvar)
%CSOLVETREE find marginal on a list of variables when the potential attached 
%to node is replace by a new belief potential.
% TREE binary join tree number
% NODE updatenode where potential will be updated by adding new belief
% ADDEDBEL added belief
% LISTVAR the list of variables for which marginal is requested
% Last update 12/10/02

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

treeindx = extfind(tree, [BJTREE(:).number]);
if treeindx == 0
    fprintf('Invalid tree number: %d.\n', tree);
    return;
end

nodeindx = extfind(updatenode, [NODE(:).number]);
if nodeindx == 0
    fprintf('Invalid node number: %d.\n', updatenode);
    return;
end

newpotindx = extfind(addedbel, [BELIEF(:).number]);
if newpotindx == 0
    fprintf('Invalid belief number: %d.\n', addedbel);
    return;
end

thenodelabel = NODE(nodeindx).vars;
thebeldomain = BELIEF(newpotindx).domain_variable;
domlesslabel = setdiff(thebeldomain, thenodelabel);
if ~isempty(domlesslabel)
    fprintf('Node label must include the potential domain.\n');
    fprintf('Updating failed.\n');
    return
end

result = clearmsge(tree, updatenode);       % clear all messages outgoing from node

if isempty(NODE(nodeindx).potential)        % update the potential in node
    NODE(nodeindx).potential = addedbel;
else
    NODE(nodeindx).potential = bcombine(NODE(nodeindx).potential, addedbel);
end
outputbel = solvetreevar(tree, listvar);
%%%%%%%%%%%%%%%%% end of CSOLVETREE
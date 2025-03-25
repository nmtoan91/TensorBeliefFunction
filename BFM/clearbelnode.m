function result = clearbelnode(tree)
% CLEARBELNODE clear all beliefs and nodes which are not attached to the tree.
% INPUT 
%   TREE tree number
% OUTPUT result = 1 means OK; result = 0 means abnormal

global BELIEF BELTRACE NODE BJTREE;

result = 1;
treeindx = extfind(tree, [BJTREE(:).number]);
if treeindx == 0
    fprintf('Invalid tree number: %d.\n', tree);
    result = 0;
    return;
end

treenodelist = BJTREE(treeindx).nodes;
treenodeindx = extfind(treenodelist, [NODE(:).number]);
nodetodelete = setdiff([NODE(:).number], treenodelist);
if ~isempty(nodetodelete)
	nodetodelindx = extfind(nodetodelete, [NODE(:).number]);
    nodetodelindx = nodetodelindx(find(nodetodelindx));     % remove zero
    if ~isempty(nodetodelindx)
		NODE(nodetodelindx) = [];
    end
end

connectmat = BJTREE(treeindx).connection;
rowcolmesg = BJTREE(treeindx).msgerow_column;
colrowmesg = BJTREE(treeindx).msgecolumn_row;
twowaymessage = rowcolmesg + colrowmesg';

treenodeindx = extfind(treenodelist, [NODE(:).number]); % indx on update nodelist
potentiallist = [NODE(treenodeindx).potential];
marginallist = [NODE(treenodeindx).marginal];
messagelist = twowaymessage(find(twowaymessage));
beltokeep = cat(2, potentiallist, marginallist, messagelist(:)');
beltodelete = setdiff([BELIEF(:).number], beltokeep);
if ~isempty(beltodelete)
    beltodelindx = extfind(beltodelete, [BELIEF(:).number]);
    beltodelindx = beltodelindx(find(beltodelindx));
    if ~isempty(beltodelindx)
		BELIEF(beltodelindx) = [];
    end
    
    tracetodelindx = extfind(beltodelete, [BELTRACE(:).bel_out]);   % remove beltrace rec
    tracetodelindx = tracetodelindx(find(tracetodelindx));
    if ~isempty(tracetodelindx)
        BELTRACE(tracetodelindx) = [];
    end
end

potentialindx = extfind(potentiallist, [BELIEF(:).number]); % change the status of potentials to user's input
potentialindx = potentialindx(find(potentialindx));
for i =1:length(potentialindx)
    BELIEF(potentialindx(i)).disposable = 0;
end

%%%%%%% end of CLEARBELNODE
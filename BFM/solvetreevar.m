function belout = solvetreevar(tree, varlist)
% SOLVETREEVAR find a marginal for the list of variables based on the
% structure of a tree.
% Input
%   binary join tree id number
%   list of variables
% Output: id number of bel that contains the marginal

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

thetreeindx = extfind(tree, [BJTREE(:).number]);
thenodelist = BJTREE(thetreeindx).nodes;
connmatrix = BJTREE(thetreeindx).connection;
messagerow_col = BJTREE(thetreeindx).msgerow_column;
messagecol_row = BJTREE(thetreeindx).msgecolumn_row;

nodelistindx = extfind(thenodelist, [NODE(:).number]);
nnodes = length(thenodelist);

if ischar(varlist)
    listvar_name = varlist;
    cellvarname = readwords(listvar_name);
    indxvarinput = extstrmatch(cellvarname, {VARIABLE(:).full_name});
    if ~isempty(find(indxvarinput==0))
        error('Variable(s) in query are not defined')
    end
    varlist = [VARIABLE(indxvarinput).number];
end
nvars = length(varlist);
varlist = sort(varlist);

finalnode = 0;
finalmarginal = 0;
supernodelist = [];
for i=1:nnodes
    thisnodeindx = nodelistindx(i);
    thisnodelabel = NODE(thisnodeindx).vars;
    if isempty(setdiff(varlist, thisnodelabel))     % varlist is a subset of node label
        supernodelist = [supernodelist thenodelist(i)];
        if ~isempty(NODE(thisnodeindx).marginal)
            finalmarginal = NODE(thisnodeindx).marginal;
            finalnodelabel = NODE(thisnodeindx).vars;
            break
        end
    end
end

if finalmarginal == 0       % calculate marginal
    if isempty(supernodelist)   % can not use tree in this procedure
        finalmarginal = solve(listpotential, varlist);
    else                        % use tree
        nrsupernode = length(supernodelist);
        supernlistindx = extfind(supernodelist, [NODE(:).number]);
        nodelabellens = zeros(1, nrsupernode);
        for j = 1:nrsupernode
            nodelabellens(j) = length(NODE(supernlistindx(j)).vars);
        end
        tmpnodelen = cat(2, supernodelist', nodelabellens');
        sortnodelen = sortrows(tmpnodelen, 2);
        finalnode = sortnodelen(1,1);       % smallest supernode idnumber
        finalnodeindx = extfind(finalnode, [NODE(:).number]);
        finalnodelabel = NODE(finalnodeindx).vars;
		finalmarginal = solvetreenode(tree,finalnode);
    end
end
        
if ~isempty(setdiff(finalnodelabel, varlist))
    belout = bproject(finalmarginal, varlist);
else
    belout = finalmarginal;
end
%%% end of SOLVETREEVAR
function showtree(treeidnumber)
%SHOWTREE shows structure of the binary join tree (non-graphic)
% Input: treeidnumber tree id_number
% Output: 2 matrices
%   1st matrix consists of 4 columns: row-node, col-node, row-col message,
%   col-row message; number of rows is the number of edges
%   2nd matrix on nodes. It has 3 columns: node id, variables in node,
%   potential

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

treeindx = extfind(treeidnumber, [BJTREE(:).number]);

connmat = BJTREE(treeindx).connection;
nodelist = BJTREE(treeindx).nodes;
row_colmat = BJTREE(treeindx).msgerow_column;
col_rowmat = BJTREE(treeindx).msgecolumn_row;

[r,c,v] = find(connmat);
mat1_col1 = (nodelist(r'))';
mat1_col2 = (nodelist(c'))';

connectpoints = (connmat == 1);
mat1_col3 = row_colmat(connectpoints);
mat1_col4 = col_rowmat(connectpoints);

matrix1 = cat(2, mat1_col1, mat1_col2, mat1_col3(:), mat1_col4(:));
fprintf('%43s\n', repmat('-',[1,43]));
fprintf('%10s %10s %10s %10s\n', 'R-node', 'C-node', 'Row->Col', 'Col->Row');
fprintf('%43s\n', repmat('-',[1,43]));
fprintf('%10d %10d %10d %10d\n', matrix1');

nodeindxlist = extfind(nodelist, [NODE(:).number]);
nnodes = length(nodelist);
strlong = sprintf('%5d',nodelist);
mat2_col1 = reshape(strlong', [5, nnodes])';

nodelabel = cell(nnodes,1);
allvarintree = [];
for i=1:nnodes
    thislabel = sort(NODE(nodeindxlist(i)).vars);
    allvarintree = union(allvarintree, thislabel);
    nodelabel{i} = thislabel;
end

nrofvarintree = length(allvarintree);
labelmat = repmat(' ', [nnodes, 5*nrofvarintree]);  % char matrix for label
for i=1:nnodes
    tmp_label = repmat(' ', [1, 5*nrofvarintree]);
    thislabel = nodelabel{i};
    thislabelvarsindx = extfind(thislabel, allvarintree);
    thislabellen = length(thislabel);
    for j=1:thislabellen
        startpos = (thislabelvarsindx(j)-1)*5 + 1;
        finpos = startpos + 4;
        varnumber = thislabel(j);
        varindx = extfind(varnumber, [VARIABLE(:).number]);
        varshortname = VARIABLE(varindx).short_name;
        tmp_label(startpos:finpos) = sprintf('%5s',varshortname);
    end
    labelmat(i,:) = tmp_label;
end

mat2_col3 = repmat(' ', [nnodes ,5]);
for i=1:nnodes
    if ~isempty(NODE(nodeindxlist(i)).potential)
        s = sprintf('%5d', NODE(nodeindxlist(i)).potential);
        mat2_col3(i,:) = s;
    end
end

mat2_col4 = repmat(' ', [nnodes, 9]);
for i=1:nnodes
    if ~isempty(NODE(nodeindxlist(i)).marginal)
        s = sprintf('%9d', NODE(nodeindxlist(i)).marginal);
        mat2_col4(i,:) = s;
    end
end

lenc1 = length(mat2_col1(1,:));
header1 = strvcat(repmat('-',[1, lenc1]), 'Node', repmat('-',[1, lenc1]));
block1 = cat(1, header1, mat2_col1);

lenc2 = length(labelmat(1,:));
header2 = strvcat(repmat('-',[1, lenc2]), '    Node labels', repmat('-',[1, lenc2]));
block2 = cat(1, header2, labelmat);

lenc3 = length(mat2_col3(1,:));
header3 = strvcat(repmat('-',[1, lenc3]), '  Pot', repmat('-',[1, lenc3]));
block3 = cat(1, header3, mat2_col3);

lenc4 = length(mat2_col4(1,:));
header4 = strvcat(repmat('-',[1, lenc4]), ' Marginal', repmat('-',[1, lenc4]));
block4 = cat(1, header4, mat2_col4);

Nodes = [block1 block2 block3 block4]
%%%% end of SHOWTREE
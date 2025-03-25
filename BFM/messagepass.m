function messagebelid = messagepass(tree, fromnode, tonode)
% MESSAGEPASS calculates the message (belief potential) that is to be
% passes from a node to another node in a binary join tree
% Input: 
%   tree - binary join tree number
%   fromnode - node id number from which message is going out
%   tonode - node id number to which message is coming to
% Output: messagebelid belief id number representing the message

global BELIEF VARIABLE NODE BJTREE;

thetreeindx = extfind(tree, [BJTREE(:).number]);
treenodelist = BJTREE(thetreeindx).nodes;
connmatrix = BJTREE(thetreeindx).connection;
nnodeintree = length(treenodelist);

messagematrix = BJTREE(thetreeindx).msgerow_column + BJTREE(thetreeindx).msgecolumn_row';       % combine 2 message mats in 1
[fromcol, tocol, belnumcol] = find(messagematrix);  % three columns contains
nrofmessages = length(belnumcol);

if ~ismember(fromnode, treenodelist) | ~ismember(tonode, treenodelist)
    error('A node given is not in the binary join tree.');
end

fromnodepos = extfind(fromnode, treenodelist);
tonodepos = extfind(tonode, treenodelist);
if (connmatrix(fromnodepos, tonodepos)==0 & connmatrix(tonodepos,fromnodepos)==0)
    error('Two nodes given are not neighbors in the tree.');
end

if messagematrix(fromnodepos, tonodepos) ~= 0   % message already exists do nothing
    messagebelid = messagematrix(fromnodepos, tonodepos);
    return
end
    
fromnodeindx = extfind(fromnode, [NODE(:).number]);
tonodeindx = extfind(tonode, [NODE(:).number]);
fromnodelabel = NODE(fromnodeindx).vars;
tonodelabel = NODE(tonodeindx).vars;
interface = intersect(fromnodelabel, tonodelabel);
if isempty(interface)
    error('The interface between two nodes is empty.');
end

if isempty(NODE(fromnodeindx).potential)
    frnodepotential = [];
else
    frnodepotential = NODE(fromnodeindx).potential;
end

beltocombine = frnodepotential;     % list of bels to combine

neighborlist = findneighbor(fromnode, tree);
nghbrtogetmes = setdiff(neighborlist, tonode);

if isempty(nghbrtogetmes)   % fromnode is a leave node
    if ~isempty(beltocombine)
        messagebelid = bproject(beltocombine, interface);
    else
        messagebelid = 0;
    end
else            % there are node to get message from
    nneighbors = length(nghbrtogetmes);
    for k=1:nneighbors
		frompos = extfind(nghbrtogetmes(k), treenodelist);
		topos = extfind(fromnode, treenodelist);
        messagefound = 0;
        if frompos < topos
            if (BJTREE(thetreeindx).msgerow_column(frompos, topos) ~= 0)
                messagefound = 1;
                beltocombine = [beltocombine BJTREE(thetreeindx).msgerow_column(frompos, topos)];
            end
        else
            if (BJTREE(thetreeindx).msgecolumn_row(topos,frompos) ~= 0)
                messagefound = 1;
                beltocombine = [beltocombine BJTREE(thetreeindx).msgecolumn_row(topos,frompos)];
            end
        end
            
        if messagefound == 0        % message does not exists
            inmessagenr = messagepass(tree, nghbrtogetmes(k), fromnode);    % recusive call
            % update message matrix after BJTREE is updated
            if frompos < topos
                BJTREE(thetreeindx).msgerow_column(frompos, topos) = inmessagenr;
            else
                BJTREE(thetreeindx).msgecolumn_row(topos, frompos) = inmessagenr;
            end
            beltocombine = [beltocombine inmessagenr];
        end
    end
    messagebelid = bproject(multcombine(beltocombine), interface);
end

if fromnodepos < tonodepos
    BJTREE(thetreeindx).msgerow_column(fromnodepos, tonodepos) = messagebelid;
else
    BJTREE(thetreeindx).msgecolumn_row(tonodepos, fromnodepos) = messagebelid;
end
%%%%%%%% end of MESSAGEPASS
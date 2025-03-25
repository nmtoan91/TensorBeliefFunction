function resultbels = bmbatch(filename)
% BMBATCH performs batch computation request corresponds to the scenario
% given in UIL original file.
% Input: BM file name the output of translation
% Output: result - a binary variable 1: process is carried OK; 0: process
% is terminated abnormally.

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE TRANPROTOCOL;
result = 0;
eval(sprintf('load %s', filename));
resultbels = [];

if isempty(TRANPROTOCOL.comprequest)
    fprintf('There is no computation request.\n');
    return
end

nrequests = length(TRANPROTOCOL.comprequest);
lastbel = TRANPROTOCOL.comprequest(1).lastbelnumber;
listvars = TRANPROTOCOL.comprequest(1).reqlistvars;
listbels = 1:lastbel;
varforbjt = listvars(1);
bjtnumber = bjtbuild(varforbjt, listbels);
bjtreeindx = extfind(bjtnumber, [BJTREE(:).number]);

resultbels = [resultbels solvetreevar(bjtnumber, listvars)];

if nrequests > 1    % there is additonal request after adding beliefs into the base
    for i = 2:nrequests
        newlastbel = TRANPROTOCOL.comprequest(i).lastbelnumber;
        listvars = TRANPROTOCOL.comprequest(i).reqlistvars;
        if lastbel == newlastbel    % request on the same belbase
            resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
        else        % there is new beliefs to add into the base
            if lastbel+1 == newlastbel      % one bel is added
                addbel = newlastbel;
                addbelindx = extfind(addbel, [BELIEF(:).number]);
                if addbelindx == 0
                    fprintf('The belief with id_number %d does not exist.\n', addbel);
                end
                newbeldomain = BELIEF(addbelindx).domain_variable;
                inclddomnodes = local_labelincld(bjtnumber, newbeldomain);  % list of nodes include this dom
                if ~isempty(inclddomnodes)      % some node has label including this dom
                    updatenode = inclddomnodes(1);    % select the first of the list
                    updatenodeindx = extfind(updatenode, [NODE(:).number]);
					clsmesgresult = clearmsge(bjtnumber, updatenode);       % clear all messages outgoing from node
					if isempty(NODE(updatenodeindx).potential)      % update the potential in node
                        NODE(updatenodeindx).potential = addbel;
                        listbels = [listbels addbel];               % update the belief base
					else
                        newcombel = bcombine(NODE(updatenodeindx).potential, addbel);
                        listbels = [setdiff(listbels, NODE(updatenodeindx).potential) newcombel];   % update the belief base
                        NODE(updatenodeindx).potential = newcombel;     % replace the potential
                    end
					resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
                    fprintf('Update with a single added belief # %d.\n', addbel);
                else    % rebuild bjtree
                    listbels = [listbels addbel];       % belief base is added by new bel
                    bjtnumber = bjtbuild(listvars, listbels);   % construct a new bjtree
                    fprintf('A new bjtree # %d has been constructed.\n', bjtnumber);
                    resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
                end
            else                            % more than one bels are added
                addedbels = lastbel+1:newlastbel;
                % union of domains for added beliefs
                addedbelsindx = extfind(addedbels, [BELIEF(:).number]);
                if ~isempty(find(addedbelsindx==0)) 
                    fprintf('One of added beliefs is not defined.\n');
                    return
                end
                uniondom = [];
                naddbels = length(addedbels);
                for j = 1:naddbels
                    uniondom = union(uniondom, BELIEF(addedbelsindx(j)).domain_variable);
                end
                inclddomnodes = local_labelincld(bjtnumber, uniondom);  % list of nodes include this union dom
                if ~isempty(inclddomnodes) % there is a node whose label includes union domain
                    addbel = multcombine(addedbels);
                    fprintf('The combination of newly added beliefs is %d.\n', addbel);
                    updatenode = inclddomnodes(1);    % select the first of the list
                    updatenodeindx = extfind(updatenode, [NODE(:).number]);
					clsmesgresult = clearmsge(bjtnumber, updatenode);       % clear all messages outgoing from node
					if isempty(NODE(updatenodeindx).potential)      % update the potential in node
                        NODE(updatenodeindx).potential = addbel;
                        listbels = [listbels addbel];               % update the belief base
					else
                        newcombel = bcombine(NODE(updatenodeindx).potential, addbel);
                        listbels = [setdiff(listbels, NODE(updatenodeindx).potential) newcombel];   % update the belief base
                        NODE(updatenodeindx).potential = newcombel;     % replace the potential
                    end
					resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
                    fprintf('Update with a newly combined belief # %d.\n', addbel);
                else % union domain does not fit any existing node; add bels one by one
                    updatenodelist = zeros(1,naddbels);     % to store nodes to update bels with
                    for j = 1:naddbels
                        thisbeldomain = BELIEF(addedbelsindx(j)).domain_variable;
                        inclddomnodes = local_labelincld(bjtnumber, thisbeldomain);
                        if ~isempty(inclddomnodes)   % there is a node whose label includes bel domain
                            updatenodelist(j) = inclddomnodes(1);
                        end
                    end
                    if ~isempty(find(updatenodelist==0))    % some bel does not find accomodating node. Reconst bjtree
                        listbels = [listbels addedbels];
                        bjtnumber = bjtbuild(listvars, listbels);   % construct a new bjtree
                        fprintf('A new bjtree # %d has been constructed.\n', bjtnumber);
                        resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
                    else        % update bels one by one in corr nodes
                        for j = 1:naddbels
                            updatenode = updatenodelist(j);             % node id
                            updatenodeindx = extfind(updatenode, [NODE(:).number]);
							clsmesgresult = clearmsge(bjtnumber, updatenode);       % clear all messages outgoing from node
							if isempty(NODE(updatenodeindx).potential)      % update the potential in node
                                NODE(updatenodeindx).potential = addedbels(j);
                                listbels = [listbels addedbels(j)];                % update the belief base
							else
                                newcombel = bcombine(NODE(updatenodeindx).potential, addedbels(j));
                                listbels = [setdiff(listbels, NODE(updatenodeindx).potential) newcombel];   % update the belief base
                                NODE(updatenodeindx).potential = newcombel;     % replace the potential
                            end
                            fprintf('Update a newly added belief # %d.\n', addedbels(j));
                        end
						resultbels = [resultbels solvetreevar(bjtnumber, listvars)];
                    end
                end
            end     % more than one belief added
        end         % end of processing new belief
        lastbel = newlastbel;
    end         % end of processing of each request
end             % end of processing of more than 1 requests
%%%% end of BMBATCH

function incnodelist = local_labelincld(bjtnumber, listvars)
% this LOCAL_LABELINCLD function gives the list of nodes of the given
% bjtree whose labels include the given list of variables.
% Input 
%   bjtnumber: binary join tree id number
%   listvars: list of variables id_numbers
% Output: 
% incnodelist: the list of nodes whose labels include the variables set

global VARIABLE NODE BJTREE TRANPROTOCOL; % BELIEF ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE

bjtindx = extfind(bjtnumber, [BJTREE(:).number]);
if bjtindx == 0     % no tree with given id_number
    fprintf('There is no tree with id number: %d.\n', bjtnumber);
    return
end

treenodelist = BJTREE(bjtindx).nodes;   % the nodes of the tree
treenodelistindx = extfind(treenodelist, [NODE(:).number]);
indxofzero = find(treenodelistindx==0);
if ~isempty(indxofzero)     % there is zeros in the list
    fprintf('There is no node with id_numbers: ');
    fprintf('%d ', treenodelist(indxofzero));
    fprintf('\n');
    return
end

incnodelist = [];
nnodes = length(treenodelistindx);
for i=1:nnodes
    thislabel = NODE(treenodelistindx(i)).vars;
    if isempty(setdiff(listvars, thislabel))
        incnodelist = [incnodelist treenodelist(i)];
    end
end
%%%%%%%%%%%%% end of LOCAL_LABELINCLD
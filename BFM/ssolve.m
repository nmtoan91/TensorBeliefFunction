function bel_idnum=ssolve(list_bels, list_vars)
%SSOLVE calculate the maginal belief on the list of vars from the beliefs given in the list_bels.
% the same function that SOLVE performs. But in distinction to SOLVE, SSOLVE uses the information 
% contained in QUERY database to see how much computation can be reused.
% LIST_BELS is a list of beliefs relevant to the calculation (input)
% LIST_VARS is a list of variables
% BEL_IDNUM is the id_number of the marginal belief

global BELIEF VARIABLE BELTRACE QUERY;

if nargin==1                % default case: all INPUT beliefs in the database are relevant
    list_vars = list_bels;  % the only arg is suppose to give list_vars
    list_bels=[BELIEF(:).number];
    disposibility = [BELIEF(:).disposable];
    derivbellist = find(disposibility);     % list of derivative beliefs
    if ~isempty(derivbellist)
        list_bels(derivbellist)=[];
    end
end

if ischar(list_vars)
    listvar_name = list_vars;
    cellvarname = readwords(listvar_name);
    indxvarinput = extstrmatch(cellvarname, {VARIABLE(:).full_name});
    if ~isempty(find(indxvarinput==0))
        error('Variable(s) in query are not defined')
    end
    list_vars = [VARIABLE(indxvarinput).number];
end

varbel=varbelcross(list_bels);          % take var-bel information from database
joindomain=varbel.varnums;              % all variables relevant
lenjdomain=length(joindomain);

if isempty(intersect(joindomain, list_vars))
    fprintf('Invalid request: variable to solve is not in the domain.')
    bel_idnum = 0;                      % exception - not a real belief number
    return
end

vartodelete=setdiff(joindomain, list_vars); % the list of vars to be deleted
releqlist = local_selectquery(list_bels);   % select query records that have the same belief base as list_bels
if (isempty(vartodelete) | isempty(releqlist))
	bel_idnum=solve(list_bels, list_vars);
else                                        % some vars need to be removed and the query history is not empty
    nqueries=length(releqlist);
    relqindx = extfind(releqlist, [QUERY(:).number]);
    keeplooking = 1;
    for i=1:nqueries
        if length(list_vars)==length(QUERY(relqindx(i)).qvars)
            if length(list_vars) == length(union(list_vars, QUERY(relqindx(i)).qvars))  % an exactly the same query has been done, use old result
                bel_idnum = QUERY(relqindx(i)).finalmarg;
                keeplooking = 0;
                break
            end
        end
    end
    
    if keeplooking==1       % look for a part of deletion sequence already done
        vecmatchpos = zeros(1,nqueries);    % match positions for queries
        vartodelete=chooseaseq(varbel, vartodelete);      % choose a deletion sequence
        for i=1:nqueries
            vecmatchpos(i) = local_matchhead(vartodelete, QUERY(relqindx(i)).deleteseq);
        end
        [maxmatchpos, querynum] = max(vecmatchpos);
        if maxmatchpos==0
            bel_idnum=solve(list_bels, list_vars);
        else                            % in this case some computation is saved and a new query is formed
            deletedvars=QUERY(relqindx(querynum)).deleteseq(1:maxmatchpos);
            computedbels=QUERY(relqindx(querynum)).keybelief(1:maxmatchpos);  % more than 1 bel may have been computed
            list_bels = [computedbels list_bels];
            varbel = varbelcross(list_bels);
            usedbels=var2bel(varbel, deletedvars);
            unusedbels = setdiff(list_bels, usedbels);
            if isempty(unusedbels)      % result already found
                bel_idnum=computedbels(end);
            else                        % need call to solve
                newlist_bels=unusedbels;
                bel_idnum=solve(newlist_bels, list_vars);
            end
        end
    end
end
%%%%%%%%%%%%%% end of SSOLVE

function selectedqlist=local_selectquery(bel_list)
%LOCAL_SELECTQUERY selects query entries that have belief base as the BEL_LIST
% SELECTEDQLIST is the list of selected query idnumbers

global QUERY;

selectedqlist = [];
lenquery=length(QUERY);

lenbellist=length(bel_list);
if lenquery >= 1
	for i=1:lenquery
        thisqbelbase = QUERY(i).qbelbase;
        if isempty(setdiff(thisqbelbase, bel_list)) & isempty(setdiff(bel_list, thisqbelbase))
            selectedqlist = [selectedqlist QUERY(i).number];
        end
	end
end
%%%%%%%%%%%%%% end of LOCAL_SELECTQUERY

function matchpos = local_matchhead(string1, string2)
% local_matchhead find the position on heads of string1 and string2 coinside

len1 = length(string1);
len2 = length(string2);
minlen = min(len1, len2);
matchpos = 0;

for i=1:minlen
    if ~(string1(i)==string2(i))
        break
    end
    matchpos = matchpos+1;
end
%%%%%%%%%%% end of local_matchhead

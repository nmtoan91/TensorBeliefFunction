function bel_idnum=solve(list_bels, list_vars, normmode, threshold)
% SOLVE calculate the maginal belief on the list of vars from the beliefs given in the list_bels
% LIST_BELS is a list of beliefs relevant to the calculation (input)
% LIST_VARS is a list of variables
% normmode: normalization or not
% threshold: approximation threshold (0 for no approximation)
% BEL_IDNUM is the id_number of marginal belief
% Last update: 05/09/2003

global BELIEF VARIABLE QUERY NORMAL APPRO;

if nargin==1                % default case: all beliefs entered by users in the database are relevant
    list_vars = list_bels;
    allbelnum = [BELIEF(:).number];
    userbelindx = ([BELIEF(:).disposable] == 0);
    list_bels = allbelnum(userbelindx);
elseif nargin==2
    normmode = 0;       % default value of normmode = 0
    threshold = 0;      % default value of threshold = 0
elseif nargin==3
    threshold = 0;      % default value of threshold = 0
end

NORMAL = normmode;      % set the modes
APPRO = threshold;

if ischar(list_bels)
    listbel_name = list_bels;
    cellbelname = readwords(listbel_name);
    indxbelinput = extstrmatch(cellbelname, {BELIEF(:).full_name});
    if ~isempty(find(indxbelinput==0))
        error('Belief(s) in query are not found.')
    end
    list_bels = [BELIEF(indxbelinput).number];
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
if isempty(intersect(joindomain, list_vars))
    fprintf('Invalid request: variable to solve is not in the domain.');
    bel_idnum = 0;                      % exception - not a real belief number
    return
end
vartodelete=setdiff(joindomain, list_vars); % the list of vars to be deleted
if ~isempty(vartodelete)
	vartodelete=chooseaseq(varbel, vartodelete);      % choose a deletion sequence
	nofvars=length(vartodelete);
	
	keybels=zeros(1,nofvars);               % to store the belief_numbers that obtained by removing a var
	for i=1:nofvars
        deletevar=vartodelete(i);
        varbel=removeavar(varbel, deletevar);
        keybels(i)=varbel.belnums(end);     % fprintf('keybels(%2d) = %2d\n', i, keybels(i));
	end
end

beltocombine=varbel.belnums;        % beliefs need to combine before the final report
% fprintf('List of bels to combine after removal = [%s]\n', num2str(beltocombine));

bel_idnum=multcombine(beltocombine);

% create a QUERY record
if isempty(QUERY)
    qcount = 0;
    qmaxnumber = 0;
else
    qcount = length(QUERY);
    qmaxnumber = max([QUERY(:).number]);
end

qcount = qcount+1;
qmaxnumber=qmaxnumber+1;

if ~isempty(vartodelete)
    deleteseqence=vartodelete;
	QUERY(qcount).number = qmaxnumber;
	QUERY(qcount).qvars = list_vars;
	QUERY(qcount).qbelbase = list_bels;
	QUERY(qcount).deleteseq=deleteseqence;
	QUERY(qcount).keybelief=keybels;
    QUERY(qcount).finalmarg=bel_idnum;
end
%%%%%%%%%%%%%% end of SOLVE
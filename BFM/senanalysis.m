function beloutid = senanalysis(belinput, massvecmat, targetvar, userbellist)
%SENANALYSIS does sensitivity analysis on the effect of variation of mass
% assignement on one belief on the mass calculated for a set of vars
% INPUT 
%   BELINPUT: belief input mass assinment will be varied
%   MASSVECMAT: matrix of mass vectors
%   TARGETVAR: target variable
%   USERBELLIST: the list of user's belief input

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME;

allbelnum = [BELIEF(:).number];
if nargin < 4
	userbelindx = ([BELIEF(:).disposable]==0);
	userbellist = allbelnum(userbelindx);
else
    userbelindx = extfind(userbellist, [BELIEF(:).number]);
end

inbelindx = extfind(belinput, [BELIEF(:).number]);
if inbelindx == 0
    error('Invalid belief input number.');
end

massvalues = BELIEF(inbelindx).bp.form.values;
[nroffosets, nrofmassvec] = size(massvalues);
[nrows, ncols] = size(massvecmat);
if ~(nroffosets == nrows)
    fprintf('Mass matrix is not consistent with the input belief.\n');
    return
end

userbelindx = ([BELIEF(:).disposable]==0);
allbelnum = [BELIEF(:).number];
userbellist = allbelnum(userbelindx);

if ~ismember(belinput, userbellist)
    fprintf('Input belief is not user defined.\n');
    return
end

if ischar(targetvar)
    listvar_name = targetvar;
    cellvarname = readwords(listvar_name);
    indxvarinput = extstrmatch(cellvarname, {VARIABLE(:).full_name});
    if ~isempty(find(indxvarinput==0))
        error('Variable(s) in query are not defined')
    end
    targetvar = [VARIABLE(indxvarinput).number];
end

lastbelindx  = length([BELIEF(:).number]);
maxidnumber = max([BELIEF(:).number]);
newbelindx = lastbelindx + 1;
newbelid = maxidnumber + 1;
BELIEF(newbelindx) = BELIEF(inbelindx);     % make a copy
BELIEF(newbelindx).number = newbelid;
BELIEF(newbelindx).disposable = 1;
BELIEF(newbelindx).bp.form.values = cat(2, massvalues, massvecmat);

basebellist = [setdiff(userbellist, belinput) newbelid];
beloutid = solve(basebellist, targetvar);
%%%%%%%%%% end of SENANALYSIS
function appbelidlist = approx(inbelidlist, threshold)
%APPROX does approximation for the input beliefs. It removes the foci with
% masses less than threshold and lumps those masses to the one mass
% assigned to the union of removed foci. It leaves a belief with at most 1
% focus with mass less than the threshold.
% Input: inbelidlist is the vector of id belief numbers 
% Output: appbelidlist is the vector of approximated beliefs
% by Phan Giang
% last update: April 21, 2003

if nargin == 1
    threshold = 10*eps;     % default value for the threshold
end

% check validity
global BELIEF VARIABLE FRAME;

inbelindxlist = extfind(inbelidlist, [BELIEF(:).number]);

if ~isempty(find(inbelindxlist==0))                 % invalid inbelid
    fprintf('Invalid input: belief id number: %d.\n', inbelidlist(find(inbelindxlist==0)));
    inbelindxlist = inbelindxlist(find(inbelindxlist));     % remove invalid bels from input list
    inbelidlist = inbelidlist(find(inbelindxlist));
end
appbelidlist = inbelidlist;         % copy input belids to output belids

nrbel = length(inbelidlist);

for i=1:nrbel                       % reads information related to empty focus
    cbelindx = inbelindxlist(i);    % read in the foci and masses
    cfocimat = BELIEF(cbelindx).bp.form.focal_sets;
    cmasses = BELIEF(cbelindx).bp.form.values;
    
    [nfoci, nvalvec] = size(cmasses);
    if nvalvec > 1      % there are more than 1 values vectors
        fprintf('Can''t approximate: there are more than 1 mass vectors.\n');
        continue
    end
    
    [nrows, ncols] = size(cfocimat);
    indxvec = find(cmasses < threshold);            % the positions where masses less than threshold
    if ~(isempty(indxvec) | (length(indxvec)==1))   % do nothing if at most 1 focus with small mass
        affectedmasses = cmasses(indxvec);
        sumsmallmass = sum(affectedmasses);
        cmasses(indxvec) = [];          % remove small masses
        
        affectedfoci = cfocimat(indxvec,:);
        cfocimat(indxvec,:) = [];
        newfocus = local_unionfoci(affectedfoci);
        [nrows, ncols] = size(cfocimat);

        cfocimat = cat(1, cfocimat, newfocus);
        cmasses = cat(1, cmasses, sumsmallmass);
        tmp_mat = cat(2, cfocimat, cmasses);

		% sort to purge identical focal sets; adding a number of columns that contains mass value
		[nrows, ncols]=size(tmp_mat);               % before updating
		tmp_mat=collapsemat(tmp_mat,ncols);
		[nrows, ncols]=size(tmp_mat);               % take size after collapsing
		
		tmp_mat=sortrows(tmp_mat, [ncols:-1:1]);    % sort focal sets by their masses
		tmp_mat=tmp_mat(nrows:-1:1, :);             % to have masses in descending order
        cfocimat = tmp_mat(:, 1:ncols-1);
        cmasses = tmp_mat(:, ncols);
        
        totalnrbels = length([BELIEF(:).number]);   % number of belief records in data base
        maxidnumber = max([BELIEF(:).number]);      % maximum id number
        newbelindx = totalnrbels+1;
        newidnumber = maxidnumber+1;
        
        BELIEF(newbelindx) = BELIEF(cbelindx);      % make a duplicate record 
        BELIEF(newbelindx).number = newidnumber;    % change id number
        BELIEF(newbelindx).disposable = 1;          % this record can be removed
        BELIEF(newbelindx).bp.form.focal_sets = cfocimat;
        BELIEF(newbelindx).bp.form.values = cmasses;
        
        appbelidlist(i) = newidnumber;
    end
end
%%%% end of APPROX

function focus = local_unionfoci(intmat)
%LOCAL_UNIONFOCI creates a focus by taking union of foci represented by row
% of input matrix 
% Input: intmat - 2D matrix of integers
% Output: focus - a row of integers
[nrows, ncols] = size(intmat);
focus = zeros(1, ncols);        % to store a new focus

for j = 1:ncols
    for i = 1:nrows
        focus(j) = bitor(focus(j), intmat(i,j));
    end
end
%%%% end of LOCAL_UNIONFOCI
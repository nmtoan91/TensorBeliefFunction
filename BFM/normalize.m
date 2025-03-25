function normbelidlist = normalize(inbelidlist)
%NORMALIZE does normalization for the input beliefs. If the mass assigned
% to the empty set is $k$ then after normalization the empty set will be
% removed from the set of foci and masses for other foci are multiplied by
% factor 1/(1-k).

% Input: inbelidlist is the vector of id belief numbers 
% Output: normbelidlist is the vector of normalized beliefs
% by Phan Giang
% last update: April 19, 2003

% check validity
global BELIEF VARIABLE FRAME;

inbelindxlist = extfind(inbelidlist, [BELIEF(:).number]);

if ~isempty(find(inbelindxlist==0))                 % invalid inbelid
    fprintf('Invalid input: belief id number: %d.\n', inbelidlist(find(inbelindxlist==0)));
    inbelindxlist = inbelindxlist(find(inbelindxlist));     % remove invalid bels from input list
    inbelidlist = inbelidlist(find(inbelindxlist));
end
normbelidlist = inbelidlist;        % copy input belids to output belids

nrbel = length(inbelidlist);
isnormalized = ones(nrbel, 1);      % vector of normalization, assumption: normalized
emptfocuspos = zeros(nrbel, 1);     % assumption: no empty focus

for i=1:nrbel           % reads information related to empty focus
    cbelindx = inbelindxlist(i);            % read in the foci and masses
    cfocimat = BELIEF(cbelindx).bp.form.focal_sets;
    cmasses = BELIEF(cbelindx).bp.form.values;      % this could be a matrix
    [nrfoci, nrmvec] = size(cmasses);
    
    [nrows, ncols] = size(cfocimat);
    focal_empty = zeros(1,ncols);

    for j=1:nrows
        thefocus = cfocimat(j, :);
        if isequal(thefocus, focal_empty)
            isnormalized(i) = 0;    % unnormalized
            conflictmvec = cmasses(j,:);
            if max(conflictmvec) == 1
                fprintf('Belief number %d is totally inconsistent.\n', inbelidlist(cbelindx));
                break
            end
            emptfocuspos(i) = j;
        end
    end         % match j loop    
end             % match i loop

for i = 1:nrbel         % processing
    if isnormalized(i) == 0
        fprintf('Normalizing belief # %d.\n', inbelidlist(i));
        cbelindx = inbelindxlist(i);            % read in the foci and masses
        cfocimat = BELIEF(cbelindx).bp.form.focal_sets;
        cmasses = BELIEF(cbelindx).bp.form.values;
        norcoeffvec = (1 - cmasses(emptfocuspos(i),:));     % mass to divide by
        cmasses(emptfocuspos(i),:) = [];        % remove mass of empty set
        if norcoeffvec < 0
            norcoeffvec = sum(cmasses);
        end
        cfocimat(emptfocuspos(i),:) = [];       % remove empty focus
        [nrfoci, nrmvec] = size(cmasses);       % check the size
        matcoeff = repmat(norcoeffvec, [nrfoci, 1]);    % coefficient mat
        cmasses = cmasses./matcoeff;            % adjust to normalization factor
        totalnrbels = length([BELIEF(:).number]);   % number of belief records in data base
        maxidnumber = max([BELIEF(:).number]);      % maximum id number
        newbelindx = totalnrbels+1;
        newidnumber = maxidnumber+1;
        
        BELIEF(newbelindx) = BELIEF(cbelindx);      % make a duplicate record 
        BELIEF(newbelindx).number = newidnumber;    % change id number
        BELIEF(newbelindx).disposable = 1;      % this record can be removed
        BELIEF(newbelindx).bp.form.focal_sets = cfocimat;
        BELIEF(newbelindx).bp.form.values = cmasses;
        
        normbelidlist(i) = newidnumber;
    end
end
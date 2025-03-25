function combinedbel=multcombine(list_bels)
%MULTCOMBINE combine a list of beliefs
% LIST_BELS: list of belief numbers to be combined
% COMBINEDBEL: the id_number of combination final result

global BELIEF;                      % VARIABLE MOFI ATTRIBUTE STRUCTURE FRAME;

bel_indx=extfind(list_bels, [BELIEF(:).number]);
if ~isempty(find(bel_indx==0))
    fprintf('Beliefs to combine do not exists: %d.\n', list_bels(bel_indx==0));
    list_bels = list_bels(find(bel_indx));
end
nofbels=length(list_bels);
if nofbels==0
    error('The list of beliefs is empty.');
end

if nofbels==1
    combinedbel=list_bels(1);        % nothing to do; return the input bel
else                                 % normal case multi combination
    varbelstruct=varbelcross(list_bels);
    if ~(nofbels==length(varbelstruct.belnums))
        error('Error in extracting belief information');
    end

    while nofbels > 2               % there are at least 3 bels in the list
        twobels=choosetwobel(varbelstruct);
        newbel=bcombine(twobels(1), twobels(2));
        indxusedbels = extfind(twobels, list_bels);
        list_bels(indxusedbels) = [];           % remove used bels
        list_bels = [newbel list_bels];         % add new bel in
        varbelstruct = varbelcross(list_bels);
        nofbels=length(list_bels);
    end
    combinedbel=bcombine(list_bels(1), list_bels(2));
end
%%%%%%%%%%%% end of MULTCOMBINE

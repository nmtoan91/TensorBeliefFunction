function belidlist = keepbel(inbelidlist)
% KEEPBEL clear beliefs from memory except those in a given list
% 
% Input
%   inbelidlist - list of id numbers for input beliefs
% Output: belidlist - the list of new id numbers for beliefs

global BELIEF VARIABLE FRAME;

inbelindxlist = extfind(inbelidlist, [BELIEF(:).number]);

if ~isempty(find(inbelindxlist==0))                 % invalid inbelid
    fprintf('Invalid input: belief id number: %d.\n', inbelidlist(find(inbelindxlist==0)));
    inbelindxlist = inbelindxlist(find(inbelindxlist));     % remove invalid bels from input list
    inbelidlist = inbelidlist(find(inbelindxlist));
    return;
end

allindx = 1:length([BELIEF(:).number]);
beltoclearindx = setdiff(allindx, inbelindxlist);
BELIEF(beltoclearindx) = [];
belidlist = inbelidlist;
%%%%%%%% end of KEEPBEL
function repvec = fosetrep(cardivec, wordsize)
%FOSETREP calculates the number of words and the size of last word
% input cardivec: vector of cardinalities
%       wordsize: number of bit used in a integer
% output repvec = [nwords sizelastword]
if nargin < 2
    wordsize = 50;
end

bitstrlength = prod(cardivec);      % length of bit vector for one foset
if mod(bitstrlength, wordsize) == 0
    sizelastword = wordsize;
    nwords = bitstrlength/wordsize;
else
    sizelastword = mod(bitstrlength, wordsize);
    nwords = (bitstrlength - sizelastword)/wordsize + 1;
end
repvec = [nwords sizelastword];
%%%%%%% end FOSETREP
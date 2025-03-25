function cellwords = readwords(strvec)
%READWORDS reads words from a char string
% input: strvec -- a char string
% output: cellwords -- cell array of words

currposition = 1;      % the begin position
slen = length(strvec);

wordcount = 0;
while currposition <= slen
    wordcount = wordcount+1;
    wordandpos = read1word(strvec, currposition);
    cellwords{wordcount}=wordandpos.word;
    currposition = wordandpos.lastpos+1;
end
%%%%%%%% end of READWORDS
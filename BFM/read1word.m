function wordstruc = read1word(string, position)
%READ1WORD reads a word in a string beginning from a position
% inputs 
%   string: character string
%   position: a number from which reading begins
% output: a wordstruc -- a structure that has 2 fields
%   .word -- a char string
%   .lastpos -- a integer indicating the last position of the word

delimiters='{},()';
slen = length(string);
if position > slen
    wordstruc.word=[];
    wordstruc.lastpos = position;
else
	while (isspace(string(position)) | ismember(string(position), delimiters))   % skip leading spaces
        position=position+1;
        if position > slen
            break
        end
	end
	
    if position > slen
        wordstruc.word=[];
        wordstruc.lastpos = position;
    else
		begword = position;
		while ~(isspace(string(position)) | ismember(string(position), delimiters))
            position=position+1;
            if position > slen
                break
            end
		end
		
		if position <= slen
            finword = position-1;
		else
            finword = slen;
		end
		wordstruc.word = string(begword:finword);
        wordstruc.lastpos = finword;
    end
end
%%%%%%% end of READ1WORD
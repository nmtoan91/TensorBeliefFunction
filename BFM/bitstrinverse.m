function invbitstrmat = bitstrinverse(bitstrmat)
% BITSTRINVERSE converts a matrix of char '0' and '1' into matrix of char
% in which '0' --> '1' and '1' --> '0'
% Input: bitstrmat is bit string matrix 
% Output: invbitstrmat is inversed bit string matrix

sizevec = size(bitstrmat);
longstring = bitstrmat(:);      % convert string into a long
len = length(longstring);

for i=1:len
    if longstring(i) == '0'
        longstring(i) = '1';
    elseif longstring(i) == '1'
        longstring(i) = '0';
    else
        fprintf('This bit string matrix contains char not 0 or 1.\n');
    end
end

invbitstrmat = reshape(longstring, sizevec);
%%%%%%%%% end of BITSTRINVERSE
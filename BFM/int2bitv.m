%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bitvmat=int2bitv(intmat, rowlength, word_size)
% INT2BITV converts a integer matrix into bit matrix
% INTMAT the integer matrix to be converted
% ROWLENGTH the length of bitmatrix
% WORD_SIZE number of bits used for each integer except the last in a row integer
% default value for WORD_SIZE is 50 bits.

if nargin < 2
    error('Not enough input data')
elseif nargin ==2
    word_size=50;
end

if mod(rowlength,word_size)==0      % if frame size is multiple of word_size
    lastword_size=word_size;        % calculation of # bit in the last word of address
    nwords=rowlength/word_size;
else
    lastword_size=mod(rowlength, word_size);  % size of the last word
    nwords=ceil(rowlength/word_size);
end

[rows, cols]=size(intmat);          % take the dim of input
if ~(nwords==cols)
    error('The inputs are not consistent. # of words must equal to # of columns.')
end

bitvmat=repmat('0', [rows, rowlength]); % bit vectors

if nwords==1                        % address has only 1 int
    bitvmat=dec2bin(intmat, rowlength);
else                                % address has more than 1 ints
    bitvmat(:, 1:word_size*(nwords-1))= reshape(dec2bin(intmat(:,1:(nwords-1))',word_size)',[word_size*(nwords-1), rows])';
    bitvmat(:, word_size*(nwords-1)+1:rowlength)=dec2bin(intmat(:,nwords)',lastword_size);
end
%%%%%%%%%%%%%%%%% end of INT2BITV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function intmat = bitmat2intmat(bitvmat, word_size)
%BITMAT2INTMAT converts bit vector representation into integer matrix representation
% BITVMAT is a bit matrix
% WORD_SIZE is a # of bits used to make an integer (default is 50)
% INTMAT is an array where each row is an integer representation of a focal set
%   Each integer in a row represetns a WORD_SIZE, except the last integer.
% Phan Giang 04/12/2002

% check the validity of index. A valid index must be in interval [0, cardinality+1]
if nargin < 2           % default value for word_size
    word_size=50;
end

[nrows, ncols]=size(bitvmat);   % of rows and columns in bel index matrix

% determine # of ints on each row and # bits used for the last word
if mod(ncols, word_size)==0
    nints = ncols/word_size;
    lword_size=word_size;
    tmp_bitmat=bitvmat;
else
    nints = ceil(ncols/word_size);
    lword_size=mod(ncols, word_size);
    buffer_mat=repmat(' ',[nrows, word_size-lword_size]);
    tmp_bitmat=cat(2, bitvmat, buffer_mat); % patch additional space to make the last words regular size
end

tmp_bitmat=permute(reshape(tmp_bitmat', [word_size, nints, nrows]), [2 1 3]);

intmat=zeros(nrows, nints);
for i=1:nrows          % for each page
    intmat(i,:)=bin2dec(tmp_bitmat(:,:,i))';
end
%%%%%%%%%%%%%%%%% end of BITMAT2INTMAT
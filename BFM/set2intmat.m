%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function intfocals = set2intmat(vars, belstruct)
%set2intmat converts set representation of focals into bit vector representation
% it works on one belief potential at a time
% VARS is a structure containing 2 components.
%   vars.nums: an array of variable id_numbers
%   vars.card: an array of cardinalities of variable frames.
% belstruct is a structure containing 2 components
%   belstruct.domain: an array of variable id_numbers in the belief potential
%   belstruct.indices: an array of indices of elements in focal sets, each column corresponds to a var
%       each element is represented by a row of indices
%       a row consists of -1s tells the end of a focal set
%       an index equal cardinality + 1 signifies a wildcard that can substitute for any value
%       for example if cardinalities of A and B are 60 and 2, a row [61 3] denotes the whole
%       frame AB.
% INTFOCALS is an array where each row is an integer representation of a focal set
%   Each integer in a row represetns a 50 bit word, except the last integer.
% Phan Giang 04/09/2002

% check the validity of index. A valid index must be in interval [0, cardinality+1]
temp_indx = belstruct.indices;                % take a copy of a bel's index matrix 

[nrows_indx, ncols_indx]=size(temp_indx);      % number of rows and columns in bel index matrix

if nrows_indx<=1
    error('There is no focal sets')
end

if ~isequal(temp_indx(nrows_indx,:), repmat(-1, [1,ncols_indx]))
    error('The last row of index matrix must be -1')
end

if ~isempty(temp_indx(temp_indx<-1))
    error('An index is invalid.')
end

% check presence of empty set
nullindex=zeros(1,ncols_indx);
for j=1:ncols_indx
    positions_zero=find(temp_indx(:,j)==0);
    if length(positions_zero)>1             % too many zeros
        nullindex(j)=-1;                    % invalid 
    elseif isempty(positions_zero)
        nullindex(j)=0;                     % no zero
    else
        nullindex(j)=positions_zero(1);
    end
end
if (min(nullindex)==-1) | ~(min(nullindex)==max(nullindex))
    error('Invalid specification of zero index.')
end

dom_size=length(belstruct.domain);

upperrow = zeros([1, dom_size]);  % contains the cardinalities of var frames
for n=1:dom_size
    k=find(belstruct.domain(n)==vars.nums);
    if isempty(k)
        error('The domain contains variable with unknown information.')
    elseif length(k)>1
        warning('Repeatition of ids in variable list')
    end
    upperrow(n)=vars.card(k(1));
end

card_vector=upperrow;       % the vector of cardinalities for frames in the domain

uppermat = repmat((upperrow+1), [nrows_indx,1]);     % cardinality + 1 = the wild card
if ~isempty(temp_indx(temp_indx > uppermat))
    error('An index is out of range')
end

% handle wild cards
for j=1:dom_size                                            % for each column
    wildcard_vec=find(card_vector(j)+1==temp_indx(:,j));    % contains positions of wcards
    while ~isempty(wildcard_vec)
        arow = temp_indx(wildcard_vec(1),:);            % copy the row with wcard
        subst_matrix=repmat(arow, [card_vector(j),1]);  % substitute matrix for wildcard
        subst_matrix(:,j)=[1:card_vector(j)].';         % wildcard is substituted by all
        [nrows_indx, ncols_indx]=size(temp_indx);       % take # of rows 
        if wildcard_vec(1)==1
            temp_indx=cat(1, subst_matrix, temp_indx(2:nrows_indx, :));
        elseif wildcard_vec(1)>1 & wildcard_vec(1)<nrows_indx
            temp_indx=cat(1, temp_indx(1:(wildcard_vec(1)-1),:), subst_matrix, temp_indx((wildcard_vec(1)+1):nrows_indx,:));
        end
        wildcard_vec=find(card_vector(j)+1==temp_indx(:,j));
    end
end

upperrow = cumprod(upperrow,2);     % take cummulative product of
pframe_size=upperrow(end);          % size of the product frame

upperrow = [1 upperrow(1:end-1)];   % shift vector to the right 1 position, the first pos = 1

% the column vector for offsets of elems in focal sets
positions=zeros(length(temp_indx), 1);

separate_value=sum((-2)*upperrow)+1;            % offset value of separation rows
emptyset_value=sum(-1*upperrow)+1;              % offset value for row of 0s (empty)

positions=(temp_indx-1)*upperrow'+1;            % calculation of offsets for coordinates
separate_pos=find(positions==separate_value);   % offset groups corr. to focal sets are separatd by a negative values

% calculate how many integers needed for a bit vector rep of a focal sets
% each int is used for word of 50 bits
if mod(pframe_size, 50)==0        % pframe_size is multiple of 50
    size_word = pframe_size/50;
else
    size_word = ceil(pframe_size/50); % the last word is used for less than 50 bits.
end

intfocals = zeros(length(separate_pos), size_word); % create int matrix for focal sets

bitmatrix = repmat('0', [length(separate_pos), pframe_size]);
left_mark=1;
for n=1:length(separate_pos)
    if positions(left_mark)==emptyset_value
        bitmatrix(n,:)=zeros(1,pframe_size);
    else
        bitmatrix(n, positions(left_mark:separate_pos(n)-1))='1';
	end
    left_mark=separate_pos(n)+1;
end

word_border = [0 50*[1:size_word]];      % vector of word borders
word_border(end)=pframe_size;

for i=1:size_word
    intfocals(:,i)=bin2dec(bitmatrix(:,word_border(i)+1:word_border(i+1)));
end
%%%%%%%%%%%%%% end of set2intmat

function crdnfoset = bvec2set(bitvset, vars)
%BVEC2SET converts bit vector representation of focals into set of coordinates representation
% BITVSET is a 2-D matrix. Each row is a bit vector (char 0 or 1) representation of a focal elem
% VARS is a structure containing 2 components.
%   vars.nums: a vector of variable id_numbers (only those present in belpotential)
%   vars.card: a vector of cardinalities of variable frames.
% CRDNFOSET is a structure containing 2 components
%   CRDNFOSET.domain: an array of variable id_numbers
%   CRDNFOSET.indices: a 2-D array. 
%       Each row represents a coordinates of one elem corresponding to variables
%       A row consists of -1s tells the end of a focal set
% Phan Giang 04/12/2002

[nfosets, lenbitv]=size(bitvset);      % number of rows (focal sets) and columns (frame size) 

if ~isempty(find(~(bitvset=='0' | bitvset=='1')))
    error('Input char array contains a char diff from 0 or 1')
end

prodframe_size=prod(vars.card);
if ~(prodframe_size==lenbitv)
    error('Frame size is different from the length of bit vectors.')
end

dom_size=length(vars.nums);

yesemptyfoset=0;
for i=1:nfosets             % this loop checks if an empty foset is present
    if isempty(find(bitvset(i,:)=='1'))   % take i-th row
        yesemptyfoset=yesemptyfoset+1;
    end
end
if yesemptyfoset > 1
    error('Bit matrix has more than one zero rows.')
end

serial_one = find(bitvset'=='1');   % take serial numbers of elem == '1'
num_ones=length(serial_one);

crdnfoset=zeros(num_ones+nfosets+yesemptyfoset, dom_size);    % # of proper elem + # separation + # empty elem
sepa_row=repmat(-1, [1, dom_size]);

upperrow = cumprod(vars.card);      
upperrow = [1 upperrow(1:end-1)];        % sizes of a column, a page and so on for other dims

crdnsetrow=0;               % init value for row number
for i=1:nfosets             % process row by row of bitmat
    tmp_row=bitvset(i,:);   % take i-th row of bit matrix
    serial_one = find(tmp_row=='1');   % take serial numbers of elem == '1'
    if isempty(serial_one)
        crdnsetrow=crdnsetrow+2;        % skip to next row; the current row is in 0s already
        crdnfoset(crdnsetrow,:)=sepa_row;
    else
		for i=1:length(serial_one)
            relative_serial=serial_one(i);
            crdnsetrow=crdnsetrow+1;
            for j=dom_size:-1:1             % calculate value for the last coordinate - last var
                flr=floor((relative_serial-1)/upperrow(j));
                crdnfoset(crdnsetrow,j)=flr+1;
                relative_serial=relative_serial-flr*upperrow(j);
            end
		end
        crdnsetrow=crdnsetrow+1;
        crdnfoset(crdnsetrow,:)=sepa_row;
    end
end
%%%%%%%%%%%%%% end of bvec2set
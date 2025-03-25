function outmatrix = collapsemat(inmatrix, value_columns)
% COLLAPSEMAT purges repeated rows in 2D INMATRIX, leaves only one representative
% adds values in VALUE_COLUMNS of removed rows into value of the representative.
% INMATRIX is 2D array. 
%   One column is designated as value column. 
%   Other columns are designated as address
% VALUE_COLUMNS vector of numbers of value column by default the value column is the last one.
%   A number for VALUE_COLUMN greater than number of columns in INMATRIX means all columns are address
%   default value: the value column is the last one.
% this version updated on Nov 22, 2002

[nrows, ncols]=size(inmatrix);
if (nargin==1)
    value_columns=ncols;
end

allcols = 1:ncols;              % all column numbers
keycolumns = setdiff(allcols,value_columns);    % key to compare
valcolumns = intersect(allcols,value_columns);  % valied values columns
if isempty(valcolumns)
    fprintf('Invalid value columns\n');
    return
end
nkeycols = length(keycolumns);
nvalcols = length(valcolumns);
inmatrix = inmatrix(:,[keycolumns valcolumns]); % rearrange so that value col go last
restoreorder = extfind(1:ncols, [keycolumns valcolumns]);   % to restore order of columns

if nrows > 1
	inmatrix=sortrows(inmatrix);
    zerovalues = zeros(1, nvalcols);
    toberemove = zeros(nrows, 1);      % this column marks rows to be deleted
	begin_row=1;
	next_row=2;
	while next_row<=nrows
        if isequal(inmatrix(begin_row,1:nkeycols), inmatrix(next_row,1:nkeycols))
            inmatrix(begin_row,nkeycols+1:ncols)=inmatrix(begin_row,nkeycols+1:ncols)+inmatrix(next_row,nkeycols+1:ncols);     %take cummulative mass
            inmatrix(next_row,nkeycols+1:ncols)=zerovalues;
            toberemove(next_row) = 1;  % remove this row
            next_row=next_row+1;
        else
            begin_row=next_row;
            next_row=next_row+1;
        end
	end
	rowtoremove=find(toberemove);       % purge repeated rows
	if ~isempty(rowtoremove)
        inmatrix(rowtoremove,:)=[];
	end
end
outmatrix = inmatrix;
%%%%%%%%%%%%%%% end of COLLAPSEMAT
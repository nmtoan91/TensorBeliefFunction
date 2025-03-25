function tbl = tableRows(arr, left)
% make a html table from 2-dimensional cell-array of chars
% add string left to most left column that goes all over the table
% return string
td = '<td>';
etd = '</td>';
tr = '<tr>';
etr = '</tr>';
[n,m] = size(arr);
tbl='';
for i=1:n
    tbl = strcat(tbl, tr);
    for j=1:m
        tbl = strcat(tbl,td,arr{i,j},etd);
    end
    if (i==1 && ~isempty(left))
         tbl = strcat(tbl,'<td rowspan="', num2str(n),'">', left, etd);
    end
    tbl = strcat(tbl, etr);
end
end

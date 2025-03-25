function listidnx = extstrmatch(srchforcellarray, srchincellarray)
% EXTSTRMATCH finds the indices of a cell array of strings with respect to another cell array of strings.
% input: 
%   srchforcellarray -- a cell array of strings to search
%   srchincellarray -- a cell array of strings in which search is done
% listindx: a vector of indices

nrofsearchfor = length(srchforcellarray);
totalnrofelem = length(srchincellarray);

listidnx = zeros(1, nrofsearchfor);
for i=1:nrofsearchfor
    strtosearch = srchforcellarray{i};
    indx = strmatch(strtosearch, srchincellarray, 'exact');
    if ~isempty(indx)
        listidnx(i) = indx(1);          % take the first index that matchs
    else
        listidnx(i) = 0;
    end
end
%%%%% end of extstrmatch
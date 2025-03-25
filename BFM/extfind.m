function indxvec=extfind(search_list, target_list)
% EXTFIND the indices of each elem of search_list in the target
% SEARCH_LIST and TARGET_LIST are two vectors
% for an elem s of SEARCH_LIST if s is in the TARGET_LIST then the index is stored in indxvec
% otherwise the value is 0

k=length(search_list);
indxvec=zeros(1,k);
for i=1:k
    position=find(search_list(i)==target_list);
    if isempty(position)
        indxvec(i)=0;
    else
        indxvec(i)=position(1);     % take 1st elem of the position vector in case position has length > 1
    end
end
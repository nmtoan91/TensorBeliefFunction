function arr = replaceIndByName(inptArr, transl)

[n,m] = size(inptArr);

for i=1:n
    for j=1:m
        arr{i,j} = transl{inptArr(i,j)+1,j};
    end
end

end
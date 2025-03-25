function transl = createTranslation(var)
global FRAME;
for i=1:length(var)
    for j=1:FRAME(var(i)).cardinality
        transl{j,i} = char(FRAME(var(i)).elements(j,:));
    end
end
end

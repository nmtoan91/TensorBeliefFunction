function table = showMarginal(marg)
global BELIEF;
global VARIABLE;
ind = find([BELIEF(:).number] == marg);
fc = BELIEF(ind).bp.form.focal_sets;
val = BELIEF(ind).bp.form.values;
var = BELIEF(ind).domain_variable;
card = BELIEF(ind).domain_cardinality;
[m,n] = size(fc);
nBits = prod(card);
toDo = 1:m;
for i=1:m
   if (sum(fc(i,:)) == 0)
        % normalization
        toDo = setdiff(1:m,i);
        val = val / sum(val(toDo));
        continue;
   end
end
    
k = 1;
for i = toDo
    b = [];
    for j = 1:n
        b = [b fliplr(de2bi(fc(i,j),min(50,nBits)))];
        nBits = nBits - 50;
    end
    nBits = prod(card);
    if(all(b)) 
       M{k,1} = '&Omega;'; 
    else
        dataArr = BFMdecode(find(b)-1, card);
        t = replaceIndByName(dataArr,createTranslation(var));
        %t = mat2str(dataArr);
        t = sprintf('%s,', t{:});
        t = t(1:end-1);
        M{k,1} = t;
    end
    M{k,2} = num2str(val(i),5);
    k = k +1;
end
table = strcat('<table border=1 bgcolor=#66FF99><caption>Marginal:',VARIABLE(var).full_name,'</caption>');
table = strcat(table,'<tr><th>',VARIABLE(var).full_name,'</th><th>m(*)</th></tr>');
table = strcat(table,makeHTMLTable(M),'</table>');
end
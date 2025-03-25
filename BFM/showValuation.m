function table = showValuation(name)
global BELIEF;
global VARIABLE;
ind = find(strcmp({BELIEF.full_name},name));
if (isempty(ind))
    error('myApp:argChk', 'Valuation %s does not exist', name);
end



fc = BELIEF(ind).bp.form.focal_sets;
val = BELIEF(ind).bp.form.values;
var = BELIEF(ind).domain_variable;
card = BELIEF(ind).domain_cardinality;
[m,n] = size(fc);

% TABLE HEADING %
table = strcat('<style>td { border-bottom: 1px solid #000} th{background-color:green;color:white;}</style>');
table = strcat(table,'<table border="1" cellpadding="1" cellspacing="1" bgcolor="#FFFFCC"><caption>',BELIEF(ind).full_name,'</caption>');
table = strcat(table,'<tr>');
for i=var
    table = strcat(table,'<th>',VARIABLE(i).full_name,'</th>');
end
table = strcat(table,'<th>m(*)</th></tr>');


nBits = prod(card);
for i = 1:m
    b = [];
    left = num2str(val(i),5);
    for j = 1:n
        b = [b fliplr(de2bi(fc(i,j),min(50,nBits)))];
        nBits = nBits - 50;
    end
    nBits = prod(card);
    if(all(b)) 
       table = strcat(table, '<tr><td colspan="', num2str(length(var)), '">&Omega;</td><td>', left, '</td></tr>'); 
    else
        dataArr = BFMdecode(find(b)-1, card);
        if length(var) > 1
            table = strcat(table, tableRows(replaceIndByName(dataArr,createTranslation(var)), left));
        else
            t = replaceIndByName(dataArr,createTranslation(var));
            if (length(t) > 1 )
                t = {strjoin(t,',')};
            end
            table = strcat(table, tableRows(t, left));
        end
    end

end
table = strcat(table,'</table>');
end
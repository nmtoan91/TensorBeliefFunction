function columlabels=code2label(crdnfoset, varlist)
% CODE2LABEL converts code of an element in focal sets into labels
% crdnfoset: code matrix
% varlist: the list of variables

global BELIEF FRAME VARIABLE;
ablank = ' ';

[nrows ncols] = size(crdnfoset);
nrofvars = length(varlist);

if ~(ncols==nrofvars)
    error('Number of variables is not equal to the number of columns');
end

allfranumbers=[FRAME(:).number];
allvarnumbers=[VARIABLE(:).number];

idnxvarlist = extfind(varlist, allvarnumbers);

fralist = [VARIABLE(idnxvarlist).frame];
idnxfralist = extfind(fralist, allfranumbers);

if ~isempty(find(idnxvarlist==0))
    error('A variable is not defined.');
end

framelabels = cell(nrofvars,1);
for i=1:nrofvars
    if FRAME(idnxfralist(i)).type==1        % integer interval
        framelabels{i} = FRAME(idnxfralist(i)).min : FRAME(idnxfralist(i)).max;
    else
        framelabels{i} = FRAME(idnxfralist(i)).elements;
    end
end

columlabels = cell(ncols,1);

for j=1:ncols
    tmp_col = crdnfoset(:,j);
    if FRAME(idnxfralist(j)).type==1
        frmtype = 1;
        labelwidth = 4;
        tmp_label = repmat('-', [nrows labelwidth+1]);      % an integer is convert to 4 char
    else
        frmtype = 2;
        labelwidth = length(framelabels{j}(1,:));
        tmp_label = repmat('-', [nrows labelwidth+1]);
    end
    for i=1:nrows
        if tmp_col(i)==0                        % empty focal set
            tmp_label(i,:) = repmat(ablank, [1, labelwidth+1]);
        elseif ~(tmp_col(i)==-1)
            if  frmtype==1                      % label is a number
                tmp_label(i,:) = [sprintf('%-4u', framelabels{j}(tmp_col(i))) ablank];
            else
                tmp_label(i,:) = [framelabels{j}(tmp_col(i),:) ablank];
            end
        end
    end
    columlabels{j} = tmp_label;
end
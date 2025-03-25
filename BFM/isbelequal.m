function comparesult = isbelequal(bellist1, bellist2, significance);
%ISBELEQUAL compares two lists of beliefs.
% Input: bellist1, bellist2 are 2 lists of belief id numbers.
% Output: comparesult = 1 if two lists have
%   the same length;
%   each corresponding pair of elems have
%           the same domains (as sets but may have different order of variables)
%           the same focal sets
%           the same masses (masses are different by amount not exceed 1e-5
%   Otherwise result is 0;

global BELIEF
if nargin ==2
    significance = 5;
end

listoneindx = extfind(bellist1, [BELIEF(:).number]);
listtwoindx = extfind(bellist2, [BELIEF(:).number]);
if ~isempty(find(listoneindx==0)) | ~isempty(find(listtwoindx==0))
    fprintf('Belief numbers are invalid.\n');
    return
end

smallconstant = 10^-significance;      % constant for small number

if isequal(bellist1, bellist2)     % a belief is equal to itself
    comparesult = 1;
    return
elseif ~(length(bellist1)==length(bellist2))
    comparesult = 0;
    return
end

bellen = length(bellist1);
paircomp = zeros(1,bellen);
for i=1:bellen
    belid1 = bellist1(i);
    belid2 = bellist2(i);
	beloneindx = extfind(belid1, [BELIEF(:).number]);
	beltwoindx = extfind(belid2, [BELIEF(:).number]);
	
	domainone = BELIEF(beloneindx).domain_variable;
	domaintwo = BELIEF(beltwoindx).domain_variable;
	
	comparesult = 0;        % default value is 0
	
	if ~(length(domainone) == length(domaintwo))
        return
	else
        nrofvar = length(domainone);
        sortdomone = sort(domainone);
        sortdomtwo = sort(domaintwo);
        if ~isequal(sortdomone, sortdomtwo)
            fprintf('Compare beliefs on different domains.\n');
            comparesult = 0;
            return
        end
	end
	
	if ~isequal(domainone, domaintwo)
        tmpbeltwo = chngdomorder(belid2, domainone);    % change var order of bel2 to that of bel1
	else
        tmpbeltwo = belid2;
	end
	tmpbeltwoindx = extfind(tmpbeltwo, [BELIEF(:).number]);
	
	fsintv_one = BELIEF(beloneindx).bp(1).form(1).focal_sets;
	massv_one = BELIEF(beloneindx).bp(1).form(1).values;
    tmpmatone = cat(2, fsintv_one, rounding(massv_one, significance));
    [nrows1, ncols1] = size(tmpmatone);
    tmpmatone = sortrows(tmpmatone, ncols1:-1:1);
    fsintv_one = tmpmatone(:,1:ncols1-1);
    massv_one = tmpmatone(:,ncols1);

    fsintv_two = BELIEF(tmpbeltwoindx).bp(1).form(1).focal_sets;
	massv_two = BELIEF(tmpbeltwoindx).bp(1).form(1).values;
    tmpmattwo = cat(2, fsintv_two, rounding(massv_two, significance));
    [nrows2, ncols2] = size(tmpmattwo);
    tmpmattwo = sortrows(tmpmattwo, ncols2:-1:1);
    fsintv_two = tmpmattwo(:,1:ncols2-1);
    massv_two = tmpmatone(:,ncols2);
	
	compfoset = isequal(fsintv_one, fsintv_two);
    if ~compfoset
        [nrows,ncols] = size(fsintv_one);
        for j=1:nrows
            if ~isequal(fsintv_one(j,:), fsintv_two(j,:))
                fprintf('Focal sets at %2d positions are not the same.\n', j);
            end
        end
    end
	compmass = isequal(massv_one,massv_two);
    if ~compmass
        diffindx = find(absdiff > smallconstant);
        for j = 1:length(diffindx)
            fprintf('Mass1 = %2d   Mass2 = %2d\n', massv_one(diffindx(j)), massv_two(diffindx(j)));
        end
    end
	paircomp(i) = compfoset & compmass;
end
comparesult = isempty(find(paircomp==0));
%%%%%%%%% end of ISBELEQUAL
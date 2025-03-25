function errormat = chckcomb(belid1, belid2, belid3)
%CHCKCOMB check correctness of combination implementation against a number
%of properties must be satisfied: commutativity and associativity.
% Input: belid1, belid2, belid3 are belief id numbers
% Output: errormat

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

if nargin==2        % check commutativity
	belsindx = extfind([belid1 belid2], [BELIEF(:).number]);
	if ~isempty(find(belsindx==0))
        fprintf('Belief numbers are invalid.\n');
        return
	end
	
	listbelone = local_belperm(belid1);
	listbeltwo = local_belperm(belid2);
	
	lenone = length(listbelone);
	lentwo = length(listbeltwo);
	
	belcombmat = zeros(lenone, lentwo);
	for i=1:lenone
        for j=1:lentwo
            belcombmat(i,j) = bcombine(listbelone(i), listbeltwo(j));
        end
	end
	
	outmat = zeros(lenone, lentwo);
	firsbel = belcombmat(1);
	outmat(1) = 1;
	for k=2:(lenone*lentwo)
        outmat(k) = isbelequal(firsbel, belcombmat(k));
	end
	[r,c,v]=find(outmat==0);
	errormat = [r c v];
	
	if isempty(errormat)
        fprintf('OK\n');
	else
		belindxone = extfind(belid1, [BELIEF(:).number]);
		beldomone = BELIEF(belindxone).domain_variable;
		varordermatone = perms(beldomone);
		
		belindxtwo = extfind(belid2, [BELIEF(:).number]);
		beldomtwo = BELIEF(belindxtwo).domain_variable;
		varordermattwo = perms(beldomtwo);
		
		blockone = zeros(length(r), length(beldomone));
		blocktwo = zeros(length(c), length(beldomtwo));
		
		for i=1:length(r)
            blockone(i,:) = varordermatone(r(i),:);
            blocktwo(i,:) = varordermattwo(c(i),:);
		end
        
        fprintf('Variable orders for bels\n');
		for i=1:length(r)
            fprintf('[');
            fprintf('%5d', blockone(i,:));
            fprintf(']   ');
            fprintf('[');
            fprintf('%5d', blocktwo(i,:));
            fprintf(']');
            fprintf('\n');
		end
	end
    
elseif nargin == 3      % check associativity
	belsindx = extfind([belid1 belid2 belid3], [BELIEF(:).number]);
	if ~isempty(find(belsindx==0))
        fprintf('Belief numbers are invalid.\n');
        return
	end
    combelone = bcombine(bcombine(belid1, belid2), belid3);
    combeltwo = bcombine(bcombine(belid2, belid3), belid1);
    combelthr = bcombine(bcombine(belid1, belid3), belid2);
    compavec = ones(1,3);
    compavec(2) = isbelequal(combelone,combeltwo);
    compavec(3) = isbelequal(combelone,combelthr);
    if isempty(find(compavec==0))
        fprintf('OK.\n');
    else
        fprintf('The standard order: bcombine(bcombine(%3d,%3d),%3d)\n',belid1, belid2,belid3);
        if compavec(2) == 0
            fprintf('Differs from order: bcombine(bcombine(%3d, %3d), %3d))',belid2, belid3, belid1);
        elseif compavec(3) == 0
            fprintf('Differes from order: bcombine(bcombine(%3d, %3d), %3d))',belid1, belid3, belid2);
        end
    end
end    
%%%%%%%%%%%%%%%%%% end of CHCKCOMB

%%%%%%%%%%%
function listbel = local_belperm(belid)

global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE;

belindx = extfind(belid, [BELIEF(:).number]);
thisbeldom = BELIEF(belindx).domain_variable;
varordermat = perms(thisbeldom);

[nofperms nofvars] = size(varordermat);
listbel = zeros(1, nofperms);

for i=1:nofperms
    thisvarorder = varordermat(i,:);
    listbel(i) = chngdomorder(belid,thisvarorder);
end
%%%%%%%%%%%% end of BELPERM
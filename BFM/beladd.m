function  varbel=beladd(invarbel, bels)
%BELADD add beliefs in BELS to a var-bel structure and outputs new var-bel structure
% INVARBEL var-bel structure with 5 fields (varnums, varcard, belnums, belcard and cross)
% BELS  list of beliefs to be added to INVARBEL
% VARBEL out updated var-bel structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global BELIEF; %VARIABLE MOFI ATTRIBUTE STRUCTURE FRAME

[nvars, nbels]=size(invarbel.cross);            % number of variables and beliefs

bels=setdiff(bels, invarbel.belnums);           % removes from the addition list bels that are already in 
if ~isempty(bels)
    allbelnumbers=[BELIEF(:).number];
    toaddvarbel=zeros(nvars, length(bels));     % var-incidence of newly added beliefs
    toaddbel_card=zeros(1, length(bels));       % cardinality of newly added beliefs
    for j=1:length(bels)
        var_vec=zeros(nvars,1);                 % template for a column in var-bel
        bel_indx=find(allbelnumbers==bels(j));
        if isempty(bel_indx)
            error('Could not find belief with id_number.')
        end
        [nfosets, nwords]=size(BELIEF(bel_indx).bp(1).form(1).focal_sets);
        toaddbel_card(j)=nfosets;
        
        bel_domain=BELIEF(bel_indx).domain_variable;
        var_indx = extfind(bel_domain, invarbel.varnums);
        if ~isempty(find(var_indx==0))
            error('A variable in adding belief is not defined.')
        end
        var_vec(var_indx)=1;
        toaddvarbel(:,j)=var_vec(:);
    end
    invarbel.belnums=cat(2, invarbel.belnums, bels);
    invarbel.belcard=cat(2, invarbel.belcard, toaddbel_card);
    invarbel.cross = cat(2, invarbel.cross, toaddvarbel);
end
varbel=invarbel;
%%%%%%%%%%%%% end of BELADD
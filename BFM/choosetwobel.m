function twobeliefs=choosetwobel(varbelstruct)
%CHOOSETWOBEL selects two beliefs for combination, 
%   the first one is the first belief in the VARBELSTRUCT
%   the second one is selected such that the state space of combined domain is smallest
% VARBELSTRUCT is var-bel structure with 5 fields

nofbels=length(varbelstruct.belnums);        % # of beliefs

twobeliefs=zeros(1,2);      % to store two belief numbers
twobeliefs(1)=varbelstruct.belnums(1);

statespaces=zeros(1, nofbels-1);  % to store state space sizes of possible combined domains

for j=1:nofbels-1;
    combdomain=max(varbelstruct.cross(:,1), varbelstruct.cross(:,j+1));
    var_indx=find(combdomain);
    combframe_size=prod(varbelstruct.varcard(var_indx));
    statespaces(j)=combframe_size;
end
[minsize, minindx]=min(statespaces);
twobeliefs(2)=varbelstruct.belnums(minindx+1);
%%%%%%%%%%%% end of CHOOSETWOBEL
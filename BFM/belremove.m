function varbel=belremove(invarbel, bels)
%BELREMOVE removes beliefs in BELS from a var-bel structure and outputs new var-bel structure
% INVARBEL var-bel structure with 5 fields (varnums, varcard, belnums, belcard and cross)
% BELS  list of beliefs to be removed from INVARBEL
% VARBEL out updated var-bel structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bel_indx = extfind(bels, invarbel.belnums);
bel_indx = bel_indx(find(bel_indx));        % remove 0s from index vector

invarbel.belnums(bel_indx)=[];
invarbel.belcard(bel_indx)=[];
invarbel.cross(:, bel_indx)=[];

% remove variable that no longer present in any belief
maxbyrow = max(invarbel.cross, [], 1);  % maximum elem by row
indx_zero = (maxbyrow == 0);            % position of variables no longer relevant
invarbel.varcard(indx_zero)=[];
invarbel.varnums(indx_zero)=[];
invarbel.cross(indx_zero, :)=[];

varbel=invarbel;
%%%%%%%%%%%%%%% end of BELREMOVE
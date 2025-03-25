uil2bm('uilfiles\lschestclin.txt', 'bmlschest')     % translate UIL input into BM data structure
global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE TRANPROTOCOL;   % declare global var
load bmlschest                                      % load BM data for the example
emallbels = condiembed([BELIEF(:).number]);         % convert conditional belief into unconditional ones
keepbel(emallbels);                                 % clear the memory of unncessary structures
showbel(emallbels)                                  % show all beliefs for visual examination
showbel(solve(emallbels, 'T'))                      % show marginal for Tuberculosis
bjtbuild('L', emallbels)                            % build a binary join with L as the final node
showbel(solvetreeall(1))                            % calculate marginals for each individual variables
belupdate(1, 15, observe('A', 'a'))                 % add observation the patien visits Asia
showbel(solvetreeall(1))                            % recalculate marginals for all individual variables
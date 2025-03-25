uil2bm('uilfiles\captain.txt', 'bmcaptain')
global BELIEF VARIABLE ATTRIBUTE STRUCTURE FRAME QUERY BELTRACE NODE BJTREE TRANPROTOCOL;
load bmcaptain                              % load file containing BM data structure
embelall = condiembed([BELIEF(:).number]);  % convert into unconditional beliefs
keepbel(embelall);                          % clear unnecessary beliefs from memory
showbel(embelall)                           % show the input in unconditional form
showbel(solve(embelall, 'A'))               % calculate then show the marginal on Arrival delay
showbel(4)                                  % show belief on Weather and Forecast
aaa = [.8 .7 .6 .5; .2 .3 .4 .5];           % matrix reflecting variation of belief masses
showbel(senanalysis(4, aaa, 'A'))           % do sensitivity analysis then show marginal on Arrival delay
bjtbuild('A', embelall)                     % construct a binary join tree with variable A as final node
showbel(solvetreeall(1))                    % calculate marginal for all variables based on BJTree and show
showbel(7)                                  % show the Forecast
bbb = [.6 .55 .5 .45; .2 .2 .2 .2; .2 .25 .3 .35];  % a matrix of masses reflecting different Forecast
showbel(senanalysis(7, bbb, 'A', embelall))     % do sensitivity analysis on A depending on different F
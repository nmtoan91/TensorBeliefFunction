function tic
%TIC stats a stopwatch timer
% the sequence of commands: tick, operation, toc
% prints the number of seconds required for the operation
%TIC simply stores CLOCK as a global variable.
global TICTOC
TICTOC=clock;
function t=toc
%TOC reads the stopwatch timer
%TOC prints the elapsed time (in seconds) since TIC was used.
global TICTOC
if isempty(TICTOC)
    error('TIC must be called before TOC.');
end
if nargout < 1
    elapse_time=etime(clock, TICTOC)
else
    t=etime(clock, TICTOC);
end
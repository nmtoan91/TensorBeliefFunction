function record_id=birthrecord(action, bel_inputs, bel_output)
%BIRTHRECORD keeps a birth record of a belief item in the BELIEF structure.
% BELTRACE structure is used for recording.
%   BELTRACE().number: the identification number
%   BELTRACE().action: the action that creates the output belief 
%   1: projection
%   2: combination
%   3: change the order of variables in the domain
%   BELTRACE().bel_ins: list of input belief numbers
%   BELTRACE().bel_out: the id_number of belief produced

global BELTRACE;

if isempty(BELTRACE)
    trace_indx=0;
    trace_counter=0;
else
    trace_indx=length(BELTRACE);
    trace_counter=max([BELTRACE(:).number]);
end

trace_indx=trace_indx+1;
BELTRACE(trace_indx).number=trace_counter+1;
BELTRACE(trace_indx).action=action;
BELTRACE(trace_indx).bel_ins=bel_inputs;
BELTRACE(trace_indx).bel_out=bel_output;
% end of BIRTHRECORD
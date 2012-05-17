% Simulink.StateflowDataLogs.who
%
% List the contents of a StateflowDataLogs object.
%
% For a subsystem data log object named Stateflow:
%
% Stateflow.who
%
%   Lists the log names of the signals logged in the top level of
%   a StateflowDataLogs object
%
% Stateflow.who('systems')
%
%   Lists the log names of all signals including composite signals
%   (i.e., buses and muxes) but not elements of composite signals
%
% Stateflow.who('all')
%
%   Lists the log names of all signals including the elements of
%   composite signals
%
% S = Stateflow.who
%
%   Returns a cell array containing the log names of the signals
%   logged by subsystem
%
%
% Other methods for Simulink.StateflowDataLogs: unpack, whos

% Copyright 2005 The MathWorks, Inc.

% Simulink.StateflowDataLogs.unpack
%
% Extracts elements from a StateflowDataLogs object and writes them into
% the MATLAB workspace.
%
% For a stateflow data log object named 'Stateflow':
%
% Stateflow.unpack
%
%    Extracts the top level of a StateflowDataLogs object.
%
% Stateflow.unpack('systems')
%
%    Extracts all signals including composite signals (i.e., buses and muxes)
%    but not elements of composite signals
%
% Stateflow.unpack('all')
%
%    Extracts all objects including the elements of composite signals
%
% Other methods for Simulink.StateflowDataLogs: who, whos

% Copyright 2005 The MathWorks, Inc.


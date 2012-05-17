% Simulink.ScopeDataLogs.who
%
% List the contents of a ScopeDataLogs object.
%
% For a scope data log object named 'scope':
%
% scope.who
%
%   Lists the log names of the signals logged in the top level of
%   a ScopeDataLogs object
%
% scope.who('systems')
%
%   Lists the log names of all signals including composite signals
%   (i.e., buses and muxes) but not elements of composite signals
%
% scope.who('all')
%
%   Lists the log names of all signals including the elements of
%   composite signals
%
% S = scope.who
%
%   Returns a cell array containing the log names of the signals
%   logged by scope.
%
%
% Other methods for Simulink.ScopeDataLogs: unpack, whos

% Copyright 2005 The MathWorks, Inc.

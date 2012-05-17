% Simulink.ScopeDataLogs.unpack
%
% Extracts elements from a ScopeDataLogs object and writes them into
% the MATLAB workspace.
%
% For a scope data log object named 'scope':
%
% scope.unpack
%
%    Extracts the top level of a ScopeDataLogs object.
%
% scope.unpack('systems')
%
%    Extracts all signals including composite signals (i.e., buses and muxes)
%    but not elements of composite signals
%
% scope.unpack('all')
%
%    Extracts all objects including the elements of composite signals
%
% Other methods for Simulink.ScopeDataLogs: who, whos

% Copyright 2005 The MathWorks, Inc.


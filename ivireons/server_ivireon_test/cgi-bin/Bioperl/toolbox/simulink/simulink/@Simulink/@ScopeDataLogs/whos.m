% Simulink.ScopeDataLogs.whos
%
% Lists detailed information about the contents of a ScopeDataLogs object.
%
% For an object named scope:
%
% scope.whos
%
%     Lists name, number of elements, and type for each signal in the top
%     level of a ScopeDataLogs object
%
% scope.whos('systems')
%
%     Lists name, number of elements, and type for all signals including
%     composite signals (i.e., buses and muxes) but not elements of
%     composite signals
%
% scope.whos('all')
%
%     Lists name, number of elements, and type for all signals including
%     the elements of composite signals
%
% S = scope.whos
%
%     Returns an array of structures, one for each signal log
%     object in the top level of the ScopeDataLogs object.
%     The structures have the following fields:
%
%     name  --  name of the signal log object
%     elements -- number of signal log objects contained by the object
%     simulinkClass -- class of the object
%
% S = scope.whos('systems') , S = scope.whos('all')
%
%     Return similar array of structures as 'scope.who' corresponding
%     to the level of the {'systems', 'all'} argument
%
%
% Other methods for Simulink.ScopeDataLogs: unpack, who

% Copyright 2005 The MathWorks, Inc.

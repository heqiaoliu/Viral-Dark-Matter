% Simulink.StateflowDataLogs.whos
%
% Lists detailed information about the contents of a StateflowDataLogs object.
%
% For an object named Stateflow:
%
% Stateflow.whos
%
%     Lists name, number of elements, and type for each signal in the top
%     level of a StateflowDataLogs object
%
% Stateflow.whos('systems')
%
%     Lists name, number of elements, and type for all signals including
%     composite signals (i.e., buses and muxes) but not elements of
%     composite signals.
%
% Stateflow.whos('all')
%
%     Lists name, number of elements, and type for all signals including
%     the elements of composite signals
%
% S = Stateflow.whos
%
%     Returns an array of structures, one for each signal log
%     object in the top level of the StateflowDataLogs object.
%     The structures have the following fields:
%
%     name  --  name of the signal log object
%     elements -- number of signal log objects contained by the object
%     simulinkClass -- class of the object
%
% S = Stateflow.whos('systems') , S = Stateflow.whos('all')
%
%     Return similar array of structures as 'Stateflow.who' corresponding
%     to the level of the {'systems', 'all'} argument
%
%
% Other methods for Simulink.StateflowDataLogs: unpack, who

% Copyright 2005 The MathWorks, Inc.

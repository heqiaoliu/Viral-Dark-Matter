function [y,x] = lsim(PID,u,t,x0,InterpRule) %#ok<INUSL>
% Linear response simulation of PID.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:19 $

% Computability
if ~isproper(PID)
    ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','lsim')
end
% Simulate
if PID.Ts==0
    y = lsim(ss(PID),u,t,[],InterpRule);
else
    % get num and den vectors based on Ts and discretization methods
    [Num, Pole] = getTF(PID);
    Den = poly(Pole);
    % Simulate
    InitState = linsimstate('tf',{Num},{Den},0);
    y = tfsim({Num},{Den},0,u,InitState);
end
x = [];
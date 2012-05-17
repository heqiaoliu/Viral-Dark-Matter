function PIDss = slss(PID)
% State-space realization of PID for LTIMASK.
%
% This realization ensures that the order is always equal to the
% denominator order. 

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:21 $

% Revisit with Pascal
if isproper(PID)
    PIDss = slss(tf(PID));
else
    ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
end

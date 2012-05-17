function autoscaler = getAutoscaler(h)
%GETAUTOSCALER Get the autoscaler.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:33 $

ae = SimulinkFixedPoint.AutoscaleExtensions;
autoscaler = ae.getAutoscaler(h.daobject);

% [EOF]

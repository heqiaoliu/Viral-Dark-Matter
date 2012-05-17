function enablesiglog(h)
%ENABLESIGLLOG attempts to turn on signal logging for the models returns
%true if logging was set false otherwise

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/13 04:18:46 $

if(~isequal(h.daobject.SimulationStatus, 'stopped')); return; end
sys = fxptds.getpath(h.daobject.getFullName);
set_param(sys, 'SignalLogging', 'On');

% [EOF]

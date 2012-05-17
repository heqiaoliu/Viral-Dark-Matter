function setsignal(h, val)
%SETPROPVALUE   Set the PropValue.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:42 $

if(~isa(val, 'Simulink.Timeseries'))
	val = [];
end
h.Signal = val;

% [EOF]

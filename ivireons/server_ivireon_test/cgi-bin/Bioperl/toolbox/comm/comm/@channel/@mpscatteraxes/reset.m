function reset(h)
%RESET  Reset axes object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:14 $

h.multipathaxes_reset;

axis(h.AxesHandle, [-300 300 0 1 0 1]);

% Initialize flag for plotting measurements.
h.NewChannelData.MeasurementsToBePlotted = false;

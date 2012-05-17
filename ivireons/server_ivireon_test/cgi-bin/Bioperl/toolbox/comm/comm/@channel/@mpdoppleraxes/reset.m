function reset(h)
%RESET  Reset axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:27:55 $

h.multipathaxes_reset;

axis(h.AxesHandle, [-300 300 0 1]);

% Initialize flag for plotting measurements.
h.NewChannelData.MeasurementsToBePlotted = false;

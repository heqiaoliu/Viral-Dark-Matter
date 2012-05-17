function ylbl = getylabel(this)
%GETYLABEL Returns the YLabel string

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2006/11/19 21:46:03 $

if strcmpi(this.NormalizedFrequency, 'On')
    ylbl = xlate('rad/sample');
else
    ylbl = xlate('Hz');
end

ylbl = sprintf('%s (dB/%s)', xlate('Power/frequency'), ylbl);

% [EOF]

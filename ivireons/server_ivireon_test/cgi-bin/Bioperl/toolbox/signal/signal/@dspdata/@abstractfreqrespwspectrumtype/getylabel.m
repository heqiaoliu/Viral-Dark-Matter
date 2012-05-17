function ylbl = getylabel(this)
%GETYLABEL Get the ylabel.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/03/31 17:11:35 $

if this.NormalizedFrequency
    ylbl = xlate('Power/frequency (dB/rad/sample)');
else
    ylbl = xlate('Power/frequency (dB/Hz)');
end


% [EOF]

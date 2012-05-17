function xdata = calculateXData(this, nSamples)
%CALCULATEXDATA 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:34 $

if this.InheritSampleRate
    period = 1/this.DataSampleRate;
    offset = 0;
else
    offset = this.XOffset;
    period = this.SampleTime;
end

xdata = offset:period:offset+period*(nSamples-1);

% [EOF]

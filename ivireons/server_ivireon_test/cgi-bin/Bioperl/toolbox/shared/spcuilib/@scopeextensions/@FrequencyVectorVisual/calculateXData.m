function xdata = calculateXData(this, nSamples)
%CALCULATEXDATA Calculate the XData information.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:16 $

if this.IsNormalized
    sampleRate = nSamples/20;
elseif this.InheritSampleRate
    sampleRate = this.DataSampleRate;
else
    sampleRate = 1/this.SampleTime;
end
period = sampleRate/nSamples;
switch this.RangeIndex
    case 1
        offset = 0;
        nSamples = max(1, floor(nSamples/2));
    case 2
        offset = -sampleRate/2;
    case 3
        offset = 0;
end
xdata = offset:period:offset+period*(nSamples-1);

% [EOF]

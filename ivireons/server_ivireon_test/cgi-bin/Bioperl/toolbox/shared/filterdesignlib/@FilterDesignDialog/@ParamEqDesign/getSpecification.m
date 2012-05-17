function specification = getSpecification(this, laState)
%GETSPECIFICATION Get the specification.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:13:23 $

if nargin > 1 && ~isempty(laState)
    freqcons = laState.FrequencyConstraints;
    magcons  = laState.MagnitudeConstraints;
else
    freqcons = get(this, 'FrequencyConstraints');
    magcons  = get(this, 'MagnitudeConstraints');
end

switch lower(freqcons)
    case 'center frequency, bandwidth, passband width'
        specification = 'F0,BW,BWp';
    case 'center frequency, bandwidth, stopband width'
        specification = 'F0,BW,BWst';
    case 'center frequency, bandwidth'
        specification = 'N,F0,BW';
    case 'center frequency, quality factor'
        specification = 'N,F0,Qa';        
    case 'shelf type, cutoff frequency, quality factor'
        specification = 'N,F0,Fc,Qa';
    case 'shelf type, cutoff frequency, shelf slope parameter'        
        specification = 'N,F0,Fc,S';
    case 'low frequency, high frequency'
        specification = 'N,Flow,Fhigh';
end

switch lower(magcons)
    case 'reference, center frequency, bandwidth, passband'
        specification = sprintf('%s,Gref,G0,GBW,Gp', specification);
    case 'reference, center frequency, bandwidth, stopband'
        specification = sprintf('%s,Gref,G0,GBW,Gst', specification);
    case 'reference, center frequency, bandwidth, passband, stopband'
        specification = sprintf('%s,Gref,G0,GBW,Gp,Gst', specification);
    case 'reference, center frequency, bandwidth'
        specification = sprintf('%s,Gref,G0,GBW', specification);
    case 'reference, center frequency'
        specification = sprintf('%s,Gref,G0', specification);     
    case 'boost/cut'
        specification = sprintf('%s,G0', specification);                
end

% [EOF]

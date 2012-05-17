function specification = getSpecification(this, laState)
%GETSPECIFICATION Get the specification.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:18:09 $

if nargin > 1 && ~isempty(laState)
    freqcons = laState.FrequencyConstraints;
    magcons  = laState.MagnitudeConstraints;
else
    freqcons = get(this, 'FrequencyConstraints');
    magcons  = get(this, 'MagnitudeConstraints');
end

specification = 'N';

switch lower(freqcons)
    case 'center frequency and quality factor'
        specification = sprintf('%s,F0,Q', specification);
    case 'center frequency and bandwidth'
        specification = sprintf('%s,F0,BW', specification);
end

switch lower(magcons)
    case 'passband ripple'
        specification = sprintf('%s,Ap', specification);
    case 'stopband attenuation'
        specification = sprintf('%s,Ast', specification);
    case 'passband ripple and stopband attenuation'
        specification = sprintf('%s,Ap,Ast', specification);
end

% [EOF]

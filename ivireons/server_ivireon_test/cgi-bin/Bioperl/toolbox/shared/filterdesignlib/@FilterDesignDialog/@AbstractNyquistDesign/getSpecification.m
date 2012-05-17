function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/19 21:27:53 $

if nargin < 2
    laState = this;
end

if isminorder(this, laState)
    specification = 'tw,ast';
else
    
    freqcons = laState.FrequencyConstraints;
    magcons  = laState.MagnitudeConstraints;

    specification = 'n';

    if strcmpi(freqcons, 'transition width')
        specification = [specification ',tw'];
    end

    if strcmpi(magcons, 'stopband attenuation')
        specification = [specification ',ast'];
    end
end

% [EOF]

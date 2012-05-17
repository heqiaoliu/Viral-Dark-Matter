function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:27 $

if nargin < 2
    laState = this;
end

if isminorder(this, laState)
    specification = 'fst1,fp1,fp2,fst2,ast1,ap,ast2';
else
    
    freqcons = laState.FrequencyConstraints;
    magcons  = laState.MagnitudeConstraints;

    specification = 'n';
    
    switch lower(freqcons)
        case 'passband edges'
            specification = [specification ',fp1,fp2'];
        case 'stopband edges'
            specification = [specification ',fst1,fst2'];
        case 'passband and stopband edges'
            specification = [specification ',fst1,fp1,fp2,fst2'];
        case '3db points'
            specification = [specification ',f3db1,f3db2'];
        case '6db points'
            specification = [specification ',fc1,fc2'];
        case '3db points and stopband width'
            specification = [specification ',f3db1,f3db2,bwst'];
        case '3db points and passband width'
            specification = [specification ',f3db1,f3db2,bwp'];
    end
    
    switch lower(magcons)
        case 'passband ripple'
            specification = [specification ',ap'];
        case 'stopband attenuation'
            specification = [specification ',ast'];
        case 'passband ripple and stopband attenuations'
            specification = [specification ',ast1,ap,ast2'];
    end
end

% [EOF]

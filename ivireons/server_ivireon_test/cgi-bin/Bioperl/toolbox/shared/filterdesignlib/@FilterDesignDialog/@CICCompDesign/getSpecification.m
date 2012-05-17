function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/19 21:28:12 $

if nargin < 2
    laState = this;
end

if isminorder(this, laState)
    specification = 'fp,fst,ap,ast';
else
    
    freqcons = laState.FrequencyConstraints;
    magcons  = laState.MagnitudeConstraints;

    specification = 'n';

    if ~isempty(strfind(lower(freqcons), 'passband edge'))
        specification = [specification ',fp'];
    end

    if ~isempty(strfind(lower(freqcons), '6db point'))
        specification = [specification ',fc'];
    end

    if ~isempty(strfind(lower(freqcons), 'stopband edge'))
        specification = [specification ',fst'];
    end

    % Magnitudes
    if ~isempty(strfind(lower(magcons), 'passband ripple'))
        specification = [specification ',ap'];
    end

    if ~isempty(strfind(lower(magcons), 'stopband attenuation'))
        specification = [specification ',ast'];
    end
end

% [EOF]

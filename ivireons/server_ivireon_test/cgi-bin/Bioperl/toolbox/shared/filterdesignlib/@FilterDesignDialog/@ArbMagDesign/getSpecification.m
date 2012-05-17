function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:30 $

if nargin > 1
    source = laState;
else
    source = this;
end

if source.NumberOfBands > 0 || isFirstBand(source)
    if source.SpecifyDenominator && strcmpi(source.ImpulseResponse, 'iir')
        specification = 'Nb,Na,B,F,';
    else
        specification = 'N,B,F,';
    end
else
    
    if source.SpecifyDenominator && strcmpi(source.ImpulseResponse, 'iir')
        specification = 'Nb,Na,F,';
    else
        specification = 'N,F,';
    end
end

if strcmpi(this.ResponseType, 'Amplitudes')
    specification = sprintf('%sA', specification);
else
    specification = sprintf('%sH', specification');
end

% -------------------------------------------------------------------------
function b = isFirstBand(source)

% This function will return TRUE when the first band's edges are not [0 1]
% or [-1 1].

try
    fvalues = evaluatevars(source.Band1.Frequencies);
    if ~strncmpi(source.FrequencyUnits, 'normalized', 10)
        fvalues = fvalues/(evaluatevars(source.InputSampleRate)/2);
    end
catch
    fvalues = [0 1];
end

if any(fvalues(1) == [-1 0]) && fvalues(end) == 1
    b = false;
else
    b = true;
end

% [EOF]

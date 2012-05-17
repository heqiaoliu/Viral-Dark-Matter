function c = freqzinputs(this)
%FREQZINPUTS   Return a cell with the inputs for FREQZ, PHASEZ, etc.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/02/23 02:48:42 $

switch lower(this.FrequencySpecification)
    case 'nfft'
        c = {this.NFFT, this.SpectrumRange};
    case 'frequencyvector'
        c = {this.FrequencyVector};
end

if ~this.NormalizedFrequency
    c = {c{:}, this.Fs};
end

% [EOF]

function h = abs(this)
%ABS   Convert the frequency response to a magnitude response.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:06 $

opts = {'SpectrumRange', this.SpectrumRange};
if ~this.NormalizedFrequency
    opts = {'Fs', this.Fs, opts{:}};
end

h = dspdata.magresp(this.Frequencies, abs(this.Data), opts{:});

% [EOF]

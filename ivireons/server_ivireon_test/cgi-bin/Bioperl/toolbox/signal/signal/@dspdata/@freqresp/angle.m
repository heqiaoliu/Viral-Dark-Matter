function h = angle(this)
%ANGLE   Convert the frequency response to a phase respose.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:07 $

opts = {'SpectrumRange', this.SpectrumRange};
if ~this.NormalizedFrequency
    opts = {'Fs', this.Fs, opts{:}};
end

h = dspdata.phaseresp(this.Frequencies, angle(this.Data), opts{:});

% [EOF]

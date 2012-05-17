function [H, W] = thiscomputeresp4freqrange(this, H, W, isdensity, isdb)
%THISCOMPUTERESP4FREQRANGE   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:05:35 $

H = abs(H);

% Catch the case when user requested to view the data in PS form, i.e, PSD
% w/out dividing by Fs.  This is only a feature of the plotted PSD.
if ~isdensity,
    if this.NormalizedFrequency,
        Fs = 2*pi;
    else
        Fs = this.getfs;
    end
    H = H*Fs;    % Don't divide by Fs, essentially create a "PS".
end

% [EOF]

function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert the old state structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 22:49:32 $

sout = [];

if isfield(sin.freq, 'nyquist'),
    
    sin = sin.freq.nyquist;
    
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    sout.freqUnits = sin.units;
    sout.Fs        = sin.fs;
    sout.Band      = sin.band{1};
end

% [EOF]

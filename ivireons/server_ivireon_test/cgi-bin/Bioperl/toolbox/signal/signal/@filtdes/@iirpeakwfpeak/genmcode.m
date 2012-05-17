function b = genmcode(h, d)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:52:06 $

% Make sure we have the magnitude units in dB.
mu = get(d, 'MagUnits');
set(d, 'MagUnits', 'dB');

[params, values, descs, str] = getbandwidth(d);

apass = getmcode(d, 'Apass');

set(d, 'MagUnits', mu);

fs = getfsstr(d);

b = sigcodegen.mcodebuffer;

b.addcr(b.formatparams({'Fpeak', params, 'Apass'}, ...
    {getmcode(d, 'Fpeak'), values, apass}, ...
    {'Peak Frequency', descs, 'Bandwidth Attenuation'}));
b.addcr(str, designdesc(d));
b.addcr('[b, a] = iirpeak(Fpeak%s, BW%s, Apass);', fs, fs);
b.add('Hd     = dfilt.df2(b, a);');

% [EOF]

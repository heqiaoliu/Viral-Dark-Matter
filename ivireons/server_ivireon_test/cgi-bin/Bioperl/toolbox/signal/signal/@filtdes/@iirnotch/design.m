function Hd = design(h, d)
%DESIGN Design the filter

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:09:15 $

% Make sure we have the magnitude units in dB.
mu = get(d, 'MagUnits'); set(d, 'MagUnits', 'dB');
apass = get(d, 'Apass'); set(d, 'MagUnits', mu);

[b, a] = iircomb(get(d, 'Order'), getbandwidth(d), apass);
Hd     = dfilt.df2(b, a);

% [EOF]

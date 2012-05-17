function cmd = maskinfo(h, d)
%MASKINFO

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:18:45 $

bw = getbandwidth(d);
fpeak = get(d, 'Fpeak');

cmd{1}.frequency  = fpeak + [-bw/2 bw/2];
cmd{1}.filtertype = 'bandpass';
cmd{1}.freqfcn    = 'wpass';

% [EOF]

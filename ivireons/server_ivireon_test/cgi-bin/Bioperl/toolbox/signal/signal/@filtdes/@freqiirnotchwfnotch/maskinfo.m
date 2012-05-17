function cmd = maskinfo(h, d)
%MASKINFO

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:18:36 $

bw = getbandwidth(d);
fnotch = get(d, 'Fnotch');

cmd{1}.frequency  = [0 fnotch-bw/2];
cmd{1}.filtertype = 'lowpass';
cmd{1}.freqfcn    = 'wpass';

cmd{2}.frequency  = [fnotch+bw/2 getnyquist(d)];
cmd{2}.filtertype = 'highpass';
cmd{2}.freqfcn    = 'wpass';

% [EOF]

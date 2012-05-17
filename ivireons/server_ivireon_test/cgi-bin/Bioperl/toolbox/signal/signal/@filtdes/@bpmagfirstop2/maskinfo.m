function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:02:16 $

if isdb(d),
    astop = get(d, 'Astop2');
else
    astop = get(d, 'Dstop2');
end

cmd{1} = [];
cmd{2} = [];

cmd{3}.magfcn     = 'stop';
cmd{3}.amplitude  = astop;
cmd{3}.filtertype = 'lowpass';

% [EOF]

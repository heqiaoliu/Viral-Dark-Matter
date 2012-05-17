function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:01:48 $

if isdb(d),
    apass = get(d, 'Apass');
else
    apass = get(d, 'Dpass');
end

cmd{1} = [];

cmd{2}.magfcn     = 'pass';
cmd{2}.amplitude  = apass;
cmd{2}.filtertype = 'bandpass';

cmd{3} = [];

% [EOF]

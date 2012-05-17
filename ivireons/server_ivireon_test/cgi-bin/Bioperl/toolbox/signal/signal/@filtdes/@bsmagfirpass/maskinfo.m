function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:02:58 $

if isdb(d),
    apass1 = get(d, 'Apass1');
    apass2 = get(d, 'Apass2');
else
    apass1 = get(d, 'Dpass1');
    apass2 = get(d, 'Dpass2');
end

cmd{1}.magfcn     = 'pass';
cmd{1}.amplitude  = apass1;
cmd{1}.filtertype = 'lowpass';

cmd{2} = [];

cmd{3}.magfcn     = 'pass';
cmd{3}.amplitude  = apass2;
cmd{3}.filtertype = 'highpass';

% [EOF]

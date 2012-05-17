function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:07 $

cmd{1}.magfcn     = 'pass';
cmd{1}.amplitude  = [d.DpassUpper -d.DpassLower]/2;
cmd{1}.filtertype = 'lowpass';
cmd{1}.magunits   = 'linear';
cmd{1}.astop      = -d.DstopUpper;

cmd{2}.magfcn     = 'stop';
cmd{2}.amplitude  = [d.DstopUpper -d.DstopLower];
cmd{2}.filtertype = 'lowpass';
cmd{2}.magunits   = 'linear';

% [EOF]

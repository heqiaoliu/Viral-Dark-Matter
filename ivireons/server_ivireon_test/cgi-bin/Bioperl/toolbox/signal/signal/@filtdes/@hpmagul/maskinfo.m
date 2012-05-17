function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:08:45 $

cmd{1}.magfcn     = 'stop';
cmd{2}.amplitude  = [d.DstopUpper -d.DstopLower];
cmd{1}.filtertype = 'highpass';
cmd{1}.magunits   = 'linear';

cmd{2}.magfcn     = 'pass';
cmd{1}.amplitude  = [d.DpassUpper -d.DpassLower]/2;
cmd{2}.filtertype = 'highpass';
cmd{2}.magunits   = 'linear';
cmd{2}.astop      = -d.DstopUpper;

% [EOF]

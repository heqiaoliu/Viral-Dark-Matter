function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/06/25 13:18:00 $

cmd{1}.magfcn     = 'wstop';
cmd{1}.filtertype = 'highpass';
cmd{1}.weight     = get(d, 'Wstop');

cmd{2}.magfcn     = 'wpass';
cmd{2}.filtertype = 'highpass';
cmd{2}.weight     = get(d, 'Wpass');

% [EOF]

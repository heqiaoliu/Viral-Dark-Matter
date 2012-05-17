function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/10 13:47:50 $

cmd{1}.magfcn    = 'aline';
cmd{1}.amplitude = get(d, 'GroupDelayVector');
cmd{1}.properties = {'Color', [0 0 0]};

% [EOF]

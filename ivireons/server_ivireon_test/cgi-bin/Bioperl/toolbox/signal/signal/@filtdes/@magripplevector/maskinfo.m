function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:37 $

cmd{1}.magfcn     = 'aline';
cmd{1}.amplitude  = get(d, 'MagnitudeVector');
cmd{1}.properties = {'Color', [0 0 0]};

% [EOF]

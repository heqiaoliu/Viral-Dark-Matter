function cmd = maskinfo(hObj, d)
%MASKINFO Return the mask information

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:50 $

a = get(d, 'MagnitudeVector');

cmd{1}.magfcn     = 'aline';
cmd{1}.amplitude  = [a(1) a(1) reshape([a(2:end-1)' a(2:end-1)']', 1,(length(a)-2)*2), a(end) a(end)];
cmd{1}.properties = {'Color', [0 0 0]};

% [EOF]

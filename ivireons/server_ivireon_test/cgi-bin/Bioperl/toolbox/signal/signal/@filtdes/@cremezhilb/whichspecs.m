function ws = whichspecs(h)
%WHICHSPECS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:15:23 $

ws = ft_whichspecs(h);

ws(1).defval = [2400 21600];

% [EOF]

function s = info(h)
%INFO Information about a window
%   S = INFO(Hwin) returns a string matrix with information about the window.
%
%   See also SIGWIN.

%   Author: P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:35:53 $

[p, v] = thisinfo(h);
titlestr = getinfoheader(h);
infostrs = { ...
        getinfoheader(h), ...
        repmat('-', 1, size(titlestr, 2)), ...
        [strvcat(p{:}) repmat('  : ', length(p), 1), strvcat(v{:})], ...
    }; %#ok
s = strvcat(infostrs{:}); %#ok

% [EOF]

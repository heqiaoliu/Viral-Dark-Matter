function fs = getmaxfs(h)
%GETMAXFS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:25:10 $

if isempty(h.Filters)
    fs = [];
else
    fs = getmaxfs(h.Filters);
end

% [EOF]

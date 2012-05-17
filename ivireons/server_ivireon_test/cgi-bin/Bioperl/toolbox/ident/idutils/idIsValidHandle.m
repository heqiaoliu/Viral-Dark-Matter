function boo = idIsValidHandle(h)
% return true if h is a true handle

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/06/07 14:43:33 $

boo = ~isempty(h) && all(ishandle(h(:)));


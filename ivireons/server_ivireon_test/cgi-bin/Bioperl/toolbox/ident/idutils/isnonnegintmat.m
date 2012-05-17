function status = isnonnegintmat(x)
% isnonnegintmat returns True if input argument is a matrix of non negative integer entries.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:30 $

% Author(s): Qinghua Zhang

status = isnonnegrealmat(x) && all(all(x==round(x)));

% FILE END

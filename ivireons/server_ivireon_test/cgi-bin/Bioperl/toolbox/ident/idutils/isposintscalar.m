function status = isposintscalar(x)
%ISPOSINTSCALAR returns True if input argument is a scalar positive integer.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:36 $

% Author(s): Qinghua Zhang

status = isnonnegintscalar(x) && x>0;

% FILE END




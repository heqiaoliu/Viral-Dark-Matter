function status = isposintmat(x)
%ISPOSINTMAT returns True if input argument is a matrix of positive integers.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:51:41 $

% Author(s): Qinghua Zhang

status = isnonnegintmat(x) && all(all(x>0));

% FILE END

function status = isnonnegintscalar(x)
%ISNONNEGINTSCALAR returns True if input argument is a scalar non negative integer.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:31 $

% Author(s): Qinghua Zhang

status = isnonnegintmat(x) && numel(x)==1;

% FILE END


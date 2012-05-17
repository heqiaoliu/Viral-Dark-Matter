function status = isrealvec(x)
%ISREALVEC True for real vector

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:40 $

% Author(s): Qinghua Zhang

status = isreal(x) && isnumeric(x) && isvector(x);

% FILE END
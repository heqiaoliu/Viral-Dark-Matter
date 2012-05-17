function status = isrealmat(x)
%ISREALMAT True for real matrix

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:38 $

% Author(s): Qinghua Zhang

status = isreal(x) && isnumeric(x) && ndims(x)==2;

% FILE END
function status = isrealrowvec(x)
%ISREALROWVEC True for real row vector

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:39 $

% Author(s): Qinghua Zhang

status = ~isempty(x) && isreal(x) && isvector(x) && size(x,1)==1;

% FILE END
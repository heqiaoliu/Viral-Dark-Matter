function status = isposrealscalar(x)
%ISPOSREALSCALAR returns True if input argument is positive real scalar number.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:57:37 $

% Author(s): Qinghua Zhang

status = (~isempty(x)) && isnumeric(x) && isreal(x) && numel(x)==1 && isfinite(x) && (x>0);

% FILE END



function d = getmaxdelay(crs)
%GETMAXDELAY returns the maximum delay of a customreg array
%
%  D = GETMAXDELAY(C) where C is a customreg object array.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:03 $

% Author(s): Qinghua Zhang

d = 0;
for kc=1: numel(crs)
  d = max(max(d, crs(kc).Delays));
end

% FILE END
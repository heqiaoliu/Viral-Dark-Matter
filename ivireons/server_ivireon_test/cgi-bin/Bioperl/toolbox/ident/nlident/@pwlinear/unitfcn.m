function [f, g, r] = unitfcn(nlobj, x)
%UNITFUN : PWLINEAR unit function
%
%  [f, g, r] = unitfcn(nlobj, x)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:01:49 $

% Author(s): Qinghua Zhang

f = abs(x);
if nargout>1
  g = sign(x);
  r = 1;
end

% FILE END
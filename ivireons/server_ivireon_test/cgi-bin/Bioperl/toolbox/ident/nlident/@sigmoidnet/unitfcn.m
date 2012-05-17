function [f, g, r] = unitfcn(nlobj, x)
%UNITFUN : sigmoidnet unit function

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:14 $

% Author(s): Qinghua Zhang

f = 1 ./ (1 + exp(-x));

nout = nargout;

if nargout>1
  g = f .* (1-f);
  r = 1;
end

% FILE END



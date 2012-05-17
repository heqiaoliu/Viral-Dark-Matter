function  [yhat, jcb, dy_x] = getJacobian(nlobj, x, varargin)
%getJacobian: single object UNITGAIN Jacobian computation
%
%  [yhat, jcb, dy_x] = getJacobian(nlobj, x)
%  yhat: output
%  jcb: d yhat/d th (zeros)
%  dy_x: d yhat/d x (ones)
%
% doParJac: if false, jcb is not calculated.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:49:09 $

% Author(s): Qinghua Zhang

no = nargout;
yhat = x;

if no>1
  nobs = size(x,1);
  jcb = zeros(nobs, 0);
end
if no>2
  dy_x = ones(nobs,1);
end

% FILE END
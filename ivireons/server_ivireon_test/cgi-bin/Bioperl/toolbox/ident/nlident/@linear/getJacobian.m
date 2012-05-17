function  [yhat, jcb, dy_x] = getJacobian(nlobj, regmat, doParJac)
%getJacobian: single object Jacobian  
%
% doParJac: if false, jcb is not calculated.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:48:42 $

% Author(s): Qinghua Zhang

no = nargout;

if nargin<3 
    doParJac = true;
end
jcb = [];

param = nlobj.Parameters;
lincoef = param.LinearCoef;
outoffset = param.OutputOffset;

param = nlobj.Parameters;
yhat = regmat * lincoef + outoffset;
nobs = size(regmat, 1);

if no>1 && doParJac
  jcb = [regmat ones(nobs,1)];
end

if no>2
  lincoef = lincoef';
  dy_x = lincoef(ones(nobs,1), :);
%   dy_x = [lincoef(ones(nobs,1), :), outoffset(ones(nobs,1))];
end

% FILE END

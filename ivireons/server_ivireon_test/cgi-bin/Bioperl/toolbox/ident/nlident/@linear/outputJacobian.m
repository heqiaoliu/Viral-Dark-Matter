function [yhat, initFilt, jcb] = outputJacobian(nlobj,  regmat, initFilt)
%outputJacobian: output and Jacobian

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:01:15 $

% Author(s): Qinghua Zhang

no = nargout;

param = nlobj.Parameters;
lincoef = param.LinearCoef;
outoffset = param.OutputOffset;

param = nlobj.Parameters;
yhat = regmat * lincoef + outoffset;
nobs = size(regmat, 1);

if no>2
  jcb = [regmat ones(nobs,1)];
end
 
% FILE END

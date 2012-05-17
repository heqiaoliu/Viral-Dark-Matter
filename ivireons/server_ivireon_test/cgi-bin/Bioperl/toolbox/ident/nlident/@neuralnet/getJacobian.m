function  [yhat, jcb, dy_x] = getJacobian(nlobj, x, doParJac)
%getJacobian: single object Jacobian  
%
% doParJac: if false, jcb is not calculated.


% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:54:47 $

% Author(s): Qinghua Zhang

if nargin<3 
    doParJac = true;
end

if nargout<2
    yhat = soevaluate(nlobj,x);
elseif nargout==2 && doParJac
    ctrlMsgUtils.error('Ident:analysis:ParJacobianNotAvailable','NEURALNET')
else
    dy_x = numjac(nlobj,x);
    yhat = soevaluate(nlobj,x);
    jcb = [];
end


function  [yhat, jcb, dy_x] = getJacobian(nlobj, x, doParJac)
%getJacobian: single object Jacobian  
%
% doParJac: if false, jcb is not calculated.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:55:38 $

if nargin<3 
    doParJac = true;
end

if nargout<2
    yhat = soevaluate(nlobj,x);
elseif nargout==2 && doParJac
    ctrlMsgUtils.error('Ident:analysis:ParJacobianNotAvailable','TREEPARTITION')
else
    dy_x = numjac(nlobj,x);
    yhat = soevaluate(nlobj,x);
    jcb = [];
end
% FILE END
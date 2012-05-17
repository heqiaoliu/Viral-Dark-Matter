function  [yhat, jcb, dy_x] = getJacobian(nlobj, x, varargin)
%getJacobian: single object Jacobian computation of IDNLFUN objects
%
%  This method is overloaded by some subclasses of IDNLFUN.
%
%  [yhat, jcb, dy_x] = getJacobian(nlobj, x)
%  yhat: output
%  jcb: d yhat/d th
%  dy_x: d yhat/d x

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:30 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired2','getJacobian')
end

no = nargout;

if no>2
    [yhat, jcb, dy_x] = soevaluate(nlobj, x);
elseif no>1
    [yhat, jcb] = soevaluate(nlobj, x);
else
    yhat = soevaluate(nlobj, x);
end

% FILE END

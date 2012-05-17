function [yhat, initFilt, jcb] = outputJacobian(nlobj, x, initFilt)
%outputJacobian: output and Jacobian of IDNLFUN objects.
%
%  This method is overloaded by some subclasses of IDNLFUN
%
%  [yhat, initFilt, jcb] = outputJacobian(nlobj, data, initFilt)
%
% yhat: function value
% jcb: the Jacobian d yhat/d th
%initFilt: (filter init) not used here, for consistency with OE models.
%
% NOTE: this function is called instead of getJacobian because of initFilt

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:53:36 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','outputJacobian')
end

if nargout>2
    [yhat, jcb] = getJacobian(nlobj, x);
else
    yhat = evaluate(nlobj, x);
end

% FILE END
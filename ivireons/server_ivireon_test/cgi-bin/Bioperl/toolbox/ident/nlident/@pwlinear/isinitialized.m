function status = isinitialized(nlobj)
%ISINITIALIZED True for initialized nonlinearity estimator.
%
%This method, pwlinear/isinitialized, must be called with a scalar object.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:55:07 $

% Author(s): Qinghua Zhang

if isscalar(nlobj)
    status = ~isempty(nlobj.internalParameter);
else
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','isinitialized')
end

% FILE END
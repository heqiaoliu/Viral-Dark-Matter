function status = isinitialized(nlobj)
%ISINITIALIZED True for initialized nonlinearity estimator.
%
%This method, poly1d/isinitialized, must be called with a scalar object.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/02 18:54:57 $

% Author(s): Qinghua Zhang

if isscalar(nlobj)
    status = ~isempty(nlobj.Coefficients);
else
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','isinitialized')
end

% FILE END
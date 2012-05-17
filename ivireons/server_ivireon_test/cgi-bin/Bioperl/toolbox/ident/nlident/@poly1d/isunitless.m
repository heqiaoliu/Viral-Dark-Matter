function status = isunitless(obj)
%ISUNITLESS True for nonlinearity estimator object without the NumberOfUnits property.
%
%This function is applicable to scalar object only.
%
%This function, overloading idnlfun/isunitless, returns always false.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/02 18:54:58 $

% Author(s): Qinghua Zhang

if ~isscalar(obj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','isunitless')
end

status = true;

% FILE END
function status = isunitless(obj)
%ISUNITLESS True for nonlinearity estimator object without the NumberOfUnits property.
%
%This function is applicable to scalar object only.
%
%This function, idnlfun/isunitless, returning always true, is overloaded by
%subclasses of idnlfun.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:53:34 $

% Author(s): Qinghua Zhang

if ~isscalar(obj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','isunitless')
end

status = true;


% FILE END
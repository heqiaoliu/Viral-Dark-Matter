function [p, v] = thisinfo(h)
%THISINFO Information for this class (without the name)

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/07/09 18:13:51 $

[pvl, vvl] = varlen_thisinfo(h);
[param, des] = getparamnames(h);
if ~iscell(param)
    param = {param};
end
if ~iscell(des)
    des = {des};
end
p = {pvl{:}, des{:}};
ndp = length(h.DynamicProp);    % number of dynamic properties
v = cell(1, ndp+1);
v(1) = vvl;
for dpI = 1:ndp
    v(dpI+1) = {sprintf('%g', get(h, param{dpI}))};
end

% [EOF]
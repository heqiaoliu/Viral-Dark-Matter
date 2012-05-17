function [ParamNames, des] = getparamnames(hWIN)
%GETPARAMNAMES Get the name of the dynamic properties

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2008/07/09 18:13:50 $

p = hWIN.DynamicProp;
np = length(p); % number of dynamic properties.
if np==1 % to be compatible with previous outputs.
    ParamNames = p.Name;
    des = p.Description;
else
    ParamNames = cell(np, 1);
    des = cell(np, 1);
    for pI = 1:np
        ParamNames{pI} = p(pI).Name;
        des{pI} = p(pI).Description;
    end
end

% [EOF]

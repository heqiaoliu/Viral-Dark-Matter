function createdynamicprops(hWIN, propName, propType, propDes)
%CREATEDYNAMICSPROPS Create dynamic properties

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2008/07/09 18:13:49 $

if iscell(propName),
    for i=1:length(propName),
        p(i) = schema.prop(hWIN, propName{i}, propType{i}); %#ok
        set(p(i),'Description',propDes);
    end
else
    p = schema.prop(hWIN, propName, propType);
    set(p,'Description',propDes);
end

if isempty(hWIN.DynamicProp) 
    hWIN.DynamicProp = p;
else
    hWIN.DynamicProp = [hWIN.DynamicProp p];
end 

% [EOF]

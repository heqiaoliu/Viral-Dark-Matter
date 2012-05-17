function resObj = copyObj(this,ds)
%COPYOBJ     Makes a deep copy of the result object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/05/14 16:54:10 $

% Create a result object
resObj = eval(class(this));
% copy values from the properties of the source object
propNames = fieldnames(this);
for i = 1:length(propNames)
    propVal = this.(propNames{i});
    if ~(isa(propVal,'java.util.HashMap') || isa(propVal,'handle.listener'))
         resObj.(propNames{i}) = propVal;
    end
end
resObj.PropertyBag = java.util.HashMap;
% make the variable persistent to improve performance.
persistent BTN_CHANGE_THIS;
if isempty(BTN_CHANGE_THIS)
    BTN_CHANGE_THIS = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeThis');
end
resObj.PropertyBag.put('DTGROUP_CHANGE_SCOPE', BTN_CHANGE_THIS);
resObj.init(resObj.daobject,ds);

% [EOF]

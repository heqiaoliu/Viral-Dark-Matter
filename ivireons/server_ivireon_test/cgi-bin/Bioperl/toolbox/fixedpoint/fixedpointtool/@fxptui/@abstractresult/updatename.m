function updatename(h, data)
%UPDATENAME 

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:18:45 $

[fullname, path, pathitem] = fxptds.getfxptfullname(data);
h.FxptFullName = fullname;
h.Path = path;
h.PathItem = pathitem;
h.PropertyBag = java.util.HashMap;
% make the variable persistent to improve performance.
persistent BTN_CHANGE_THIS;
if isempty(BTN_CHANGE_THIS)
    BTN_CHANGE_THIS = DAStudio.message('FixedPoint:fixedPointTool:btnProposedDTsharedChangeThis');
end
h.PropertyBag.put('DTGROUP_CHANGE_SCOPE', BTN_CHANGE_THIS);

% [EOF]

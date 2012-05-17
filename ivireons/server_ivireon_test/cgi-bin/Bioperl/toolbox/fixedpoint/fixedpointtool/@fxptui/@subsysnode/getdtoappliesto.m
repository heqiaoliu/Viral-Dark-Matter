function [listselection,  list] = getdtoappliesto(h)
%GETTYPESTOVERRIDE Get the data types to override when DTO is turned on.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:16:57 $

%get the list of valid settings from the underlying object
if(h.isdominantsystem('DataTypeOverride'))
    
    list = { ...
        DAStudio.message('FixedPoint:fixedPointTool:labelAllNumericTypes'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelFloatingPoint'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelFixedPoint')};
    
    objval = h.daobject.DataTypeOverrideAppliesTo;
    %Use a switchyard instead of ismember() to improve performance.
    switch objval
        case 'AllNumericTypes'
            listselection = list{1};
        case 'Floating-point'
            listselection = list{2};
        case 'Fixed-point'
            listselection = list{3};
        otherwise
            listselection = '';
    end
else
    if(isempty(h.DTODominantSystem))
        listselection = DAStudio.message('FixedPoint:fixedPointTool:labelDisabledDatatypeOverride');
    else
        dsys_name = fxptds.getpath(h.DTODominantSystem.Name);
        listselection = DAStudio.message('FixedPoint:fixedPointTool:labelControlledBy', dsys_name);
    end
    list = {listselection};
end

% [EOF]


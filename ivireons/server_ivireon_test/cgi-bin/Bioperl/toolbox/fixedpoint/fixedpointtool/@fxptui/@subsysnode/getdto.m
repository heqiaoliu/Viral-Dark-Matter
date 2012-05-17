function [listselection, list] = getdto(h)
%GETDTO   Get the dto.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:56 $


%get the list of valid settings from the underlying object
if(h.isdominantsystem('DataTypeOverride'))
    list = { ...
        DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelScaledDoubles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelTrueDoubles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelTrueSingles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelForceOff')}';  
    objval = h.daobject.DataTypeOverride;
    % Use a switchyard instead of ismember() to improve performance.
    switch objval
      case 'UseLocalSettings'
        listselection = list{1};
      case {'ScaledDoubles', 'ScaledDouble'}
        listselection = list{2};
      case {'TrueDoubles', 'Double'}
        listselection = list{3};
      case {'TrueSingles', 'Single'}
        listselection = list{4};
      case {'ForceOff', 'Off'}
        listselection = list{5};
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

function [listselection, list] = getmmo(h)
%GETMMO   Get the mmo.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3.4.1 $  $Date: 2010/06/14 14:27:07 $

%get the list of valid settings from the underlying object
if(h.isdominantsystem('MinMaxOverflowLogging'))
    list = { ...
        DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelMinimumsMaximumsAndOverflows'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelOverflowsOnly'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelMMOForceOff')}';
    objval = h.daobject.MinMaxOverflowLogging;
    % Use a switchyard instead of ismember() to improve performance.
    switch objval
      case 'UseLocalSettings'
        listselection = list{1};
      case 'MinMaxAndOverflow'
        listselection = list{2};
      case 'OverflowOnly'
        listselection = list{3};
      case 'ForceOff'
        listselection = list{4};
      otherwise
        listselection = '';
    end
else
    if(isempty(h.MMODominantSystem))
        listselection = DAStudio.message('FixedPoint:fixedPointTool:labelNoControl');
    else
        dsys_name = fxptds.getpath(h.MMODominantSystem.Name);
        listselection = DAStudio.message('FixedPoint:fixedPointTool:labelControlledBy', dsys_name);
    end
    list = {listselection};
end
% [EOF]

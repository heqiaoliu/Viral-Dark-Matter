function [listselection, list] = getdto(h)
%GETDTO   Get the dto.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:52:57 $

% make the variables persistent to improve performance.
persistent lst;
persistent lstselection;
%get the list of valid settings from the underlying object
if isempty(lst)
    lst = { ...
        DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelScaledDoubles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelTrueDoubles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelTrueSingles'), ...
	DAStudio.message('FixedPoint:fixedPointTool:labelForceOff')}';
end
if isempty(lstselection)
    lstselection = ...
        DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings');
end
list = lst;
listselection = lstselection;


% [EOF]

function [listselection, list] = getmmo(h)
%GETMMO   Get the mmo.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:52:58 $

% Make the variables persistent to improve performance.
persistent lst;
persistent lstselection;
if isempty(lst)
    lst = {...
        DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelMinimumsMaximumsAndOverflows'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelOverflowsOnly'), ...
        DAStudio.message('FixedPoint:fixedPointTool:labelForceOff')}';
end
if isempty(lstselection)
    lstselection = DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings');
end
list = lst;
listselection = lstselection;

% [EOF]

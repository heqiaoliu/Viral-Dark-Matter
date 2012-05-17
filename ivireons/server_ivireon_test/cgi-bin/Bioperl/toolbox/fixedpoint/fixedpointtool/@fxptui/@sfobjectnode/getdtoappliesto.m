function [listselection,  list] = getdtoappliesto(h)
%GETDTOAPPLIESTO Get the dtoappliesto.
%   OUT = GETDTOAPPLIESTO(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:16:52 $

%get the list of valid settings from the underlying object
list = { ...
    DAStudio.message('FixedPoint:fixedPointTool:labelAllNumericTypes'), ...
    DAStudio.message('FixedPoint:fixedPointTool:labelFloatingPoint'), ...
    DAStudio.message('FixedPoint:fixedPointTool:labelFixedPoint')};

listselection = list{1};
   
% [EOF]

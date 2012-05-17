function hAxes = findAxes(this)
%FINDAXES Return the axes handles

%   @commscope/@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:53 $

hChildren = get(this.PrivScopeHandle, 'Children');

idx = strmatch('axes', get(hChildren, 'Type'));

hAxes = hChildren(idx);

%-------------------------------------------------------------------------------
% [EOF]

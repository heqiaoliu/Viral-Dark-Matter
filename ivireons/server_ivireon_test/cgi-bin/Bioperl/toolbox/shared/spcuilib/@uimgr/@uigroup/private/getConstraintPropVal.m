function [isOn,numOn] = getConstraintPropVal(hGroup)
%getConstraintPropVal Return cell array of constraint property values
%   from uigroup.  Assumes uigroup contains only uiitem's.
%   Returns values in "stored order", not "rendered placement-order".

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:34:14 $

isOn = logical([]);
hChild = hGroup.down; % get first child
while ~isempty(hChild)
    % Get value of widget-child of uiitem-child of uigroup
    % Make sure child widget is a valid handle
    hWidget = hChild.hWidget;
    if ~isempty(hWidget)
        v = get(hWidget, hChild.StateName); % widget state
        isOn(end+1) = strcmpi(v,'on'); %#ok
    end
    hChild = hChild.right; % next child
end
numOn = sum(isOn);

% [EOF]

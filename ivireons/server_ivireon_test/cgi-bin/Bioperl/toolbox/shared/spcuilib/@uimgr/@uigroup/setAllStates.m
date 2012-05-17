function setAllStates(h,val)
%setAllStates Set all child widget states to a given value.
%   setAllStates(hGROUP,VAL) sets each child widget state to VAL, if the
%   child widget is rendered.  Any installed SelectionConstraint will be
%   operational and will have the expected outcome on the result.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:09 $

h = h.down; % get first child
while ~isempty(h)
    % hWidget may be empty, in which case this is ignored
    hWidget = h.hWidget;
    if ~isempty(hWidget)
        set(hWidget, h.StateName, val);
    end
    h = h.right; % get next child
end

end % setAllStates

% [EOF]

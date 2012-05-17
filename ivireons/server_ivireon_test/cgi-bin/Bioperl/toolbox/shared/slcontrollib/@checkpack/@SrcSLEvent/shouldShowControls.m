function out = shouldShowControls(this, controlType) %#ok<INUSL>
%SHOULDSHOWCONTROLS For source specific control visibility
% Returns true if the controls should be visible on the scope.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:15 $

if strcmp(controlType, 'Base')
    out = true;
elseif strcmp(controlType, 'Floating')
    out = false;
else
    % don't show unknown controls
    out = false;
end
end

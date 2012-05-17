function out = shouldShowControls(this, controlType)
%SHOULDSHOWCONTROLS For source specific control visibility
% Returns true if the controls should be visible on the scope.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/07 14:24:22 $

if strcmp(controlType, 'Base')
    out = true;
elseif strcmp(controlType, 'Floating')
    out = false;
else
    % don't show unknown controls
    out = false;
end

function out = shouldShowControls(this, controlType)
%SHOULDSHOWCONTROLS For source specific control visibility
% Returns true if the controls should be visible on the scope. 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:42:24 $

if strcmp(controlType, 'Base')
    out = true;
elseif strcmp(controlType, 'Floating')
    out = true;
else
    % don't show unknown controls
    out = false;
end

% [EOF]

function syncGUIvals(this, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:41:27 $

h = findhandle(this, whichframes(this));

if ~isempty(h),
    set(this, 'DesignType', get(h, 'CurrentSelection'));
end

% [EOF]

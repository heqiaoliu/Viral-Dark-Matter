function syncGUIvals(this, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:41:21 $

h = findhandle(this, whichframes(this));

if ~isempty(h),
    set(this, 'DesignType', map(get(h, 'CurrentSelection')));
end

% ------------------------------------------------------
function dt = map(dt)

if strcmpi(dt, 'minimum-phase'),
    dt = 'minphase';
end

% [EOF]

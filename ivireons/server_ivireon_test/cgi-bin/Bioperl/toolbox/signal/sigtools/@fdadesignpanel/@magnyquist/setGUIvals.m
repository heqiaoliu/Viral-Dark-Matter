function setGUIvals(this, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:41:20 $

h = findhandle(this, whichframes(this));

if ~isempty(h),
    set(h, 'AllOptions', mapall(set(this, 'DesignType')));
    set(h, 'currentSelection', map(get(this, 'DesignType')));
end

% ---------------------------------------------
function dt = mapall(dt)

dt{3} = 'Minimum-Phase';

% ---------------------------------------------
function dt = map(dt)

if strcmpi(dt, 'minphase'),
    dt = 'Minimum-phase';
end

% [EOF]

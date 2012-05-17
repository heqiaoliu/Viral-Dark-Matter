function setGUIvals(this, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/02/23 02:53:04 $

h = findhandle(this, whichframes(this));

if ~isempty(h),
    set(h, 'Fs', get(this, 'Fs'));
    set(h, 'Units', get(this, 'freqUnits'));
    set(this.WhenRenderedListeners, 'Enabled', 'Off');
    set(h, 'freqSpecType', get(this, 'freqSpecType'));
    set(this.WhenRenderedListeners, 'Enabled', 'On');
    
    name = getdynamicname(h);
    set(h, name, get(this, name));
end

% [EOF]

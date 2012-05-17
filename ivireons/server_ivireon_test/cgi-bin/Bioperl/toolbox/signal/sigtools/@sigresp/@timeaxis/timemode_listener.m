function timemode_listener(this, eventData)
%TIMEMODE_LISTENER   Listener to the TimeMode parameter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:08 $

units = getsettings(getparameter(this, 'freqmode'), eventData);

normstr = 'samples';

if strcmpi(units, 'on')
    if disableparameter(this, 'timeunits'),
        hdlg = getcomponent(this, '-class', 'siggui.parameterdlg');
        if isempty(hdlg),
            val = get(this, 'TimeUnits');
        else
            val = getvaluesfromgui(hdlg, 'timeunits');
        end
        set(this, 'CachedTimeUnits', val);
        if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off'); end
        set(this, 'TimeUnits', normstr);
        if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On'); end
    end
else
    if enableparameter(this, 'timeunits'),
        if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off'); end
        set(this, 'TimeUnits', get(this, 'CachedTimeUnits'));
        if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On'); end
    end
end

% [EOF]

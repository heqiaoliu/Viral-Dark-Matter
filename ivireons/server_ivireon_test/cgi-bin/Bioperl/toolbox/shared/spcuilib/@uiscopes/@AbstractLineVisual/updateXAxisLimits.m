function updateXAxisLimits(this)
%UPDATEXAXISLIMITS Update the XAxis limits.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/16 22:34:39 $

if this.getPropValue('AutoDisplayLimits')
    xlim = calculateXLim(this);
else
    xlim = [evalPropValue(this, 'MinXLim') evalPropValue(this, 'MaxXLim')];
    if xlim(1) > xlim(2)
        return;
    end
end

% Disable the listeners on the limits, so that we can set it without
% turning off auto display limits.
l = get(this, 'LimitListener');
uiservices.setListenerEnable(l, false);

% Set the new limits.
set(this.Axes, 'XLim', xlim);

% Reenable the listener.
uiservices.setListenerEnable(l, true);

% [EOF]

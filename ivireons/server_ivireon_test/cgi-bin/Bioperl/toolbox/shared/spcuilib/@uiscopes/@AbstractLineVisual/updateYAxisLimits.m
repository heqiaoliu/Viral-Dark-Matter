function updateYAxisLimits(this)
%UPDATEYAXISLIMITS Update the Y-axis limits

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:34:40 $

hAxes = this.Axes;
if ishghandle(hAxes)
    try
        newYLim = [evalPropValue(this, 'MinYLim') evalPropValue(this, 'MaxYLim')];
        l = this.LimitListener;
        uiservices.setListenerEnable(l, false);
        set(hAxes, 'YLim', newYLim);
        uiservices.setListenerEnable(l, true);
    catch ME
        uiscopes.errorHandler(uiscopes.message('CannotEvaluateYLims', ...
            ME.message, get(hAxes, 'YLim')));
    end
end

% [EOF]

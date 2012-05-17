function performAutoscale(this, force)
%PERFORMAUTOSCALE Perform the autoscale action.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:07:47 $

% Get the current ylimits based on the ydata of the display in the visual.
extents = getXYZExtents(this.Application.Visual);

% If either ymin or ymax cannot be found (empty data) return early.
if any(isnan(extents)) | any(isinf(extents))
    return;
end

% If the force flag is not passed, do not force an autoscale.
if nargin < 2
    force = false;
end

% Get the min/max values out of the extents.
xmin = extents(1, 1);
xmax = extents(1, 2);
ymin = extents(2, 1);
ymax = extents(2, 2);

% Calculate the DisplayRange
hAxes = this.Application.Visual.Axes;
currentYLim = get(hAxes, 'YLim');
yLimRange   = currentYLim(2)-currentYLim(1);
expandOnly  = this.ExpandOnly;

% If we are not forcing a resize, check if we are beyond the axes limits.
if force
    shouldResize = true;
else
    shouldResize = false;
    updates = this.Updates+1;
    this.Updates = updates;
    
    % If we are completely off the display, force a resize regardless of
    % how often it happens.
    if ymin > currentYLim(2) || ymax < currentYLim(1)
        shouldResize = true;
        consecutiveGood = 0;
    else
        % If we have overrun the top or the bottom of Y-Axis, check if
        % we've been doing it a lot and force a resize if we have gone over
        % the predefined thresholds.
        if ymax > currentYLim(2) || ymin < currentYLim(1)
            
            consecutiveOver = this.ConsecutiveOver+1;
            overRuns = this.OverRuns+1;
            this.OverRuns = overRuns;
            this.ConsecutiveOver = consecutiveOver;
            
            % The threshold values below were determined via trial and
            % error to give a human-like feel for the automated scaling.
            
            % If we are allowing contraction, we want to perform the
            % autoscale less often to avoid zooming in and out.  If we are
            % only expanding, we can be a bit more aggressive with how
            % often we zoom out.
            if expandOnly
                frequency = 100;
            else
                frequency = 25;
            end
            
            % If we've over run at least 20 times and at least 5% of the
            % total updates have been overruns, force a resize.  If we've
            % seen 20 straight overruns, force a resize.
            if overRuns > 25-frequency/5 && ...
                    overRuns/updates > .2-frequency/1000 || ...
                    consecutiveOver > 25-frequency/5
                shouldResize = true;
            end
            consecutiveGood = 0;
            
        elseif (ymax-ymin)/yLimRange < .15 && ~expandOnly
            
            % If the data is taking up a significantly small area it is
            % called an "underun".  See how often this is happening and if
            % the axes should zoom in.
            consecutiveUnder = this.ConsecutiveUnder+1;
            underRuns = this.UnderRuns+1;
            this.UnderRuns = underRuns;
            this.ConsecutiveUnder = consecutiveUnder;
            if underRuns > 40 && ...
                    underRuns/updates > .4 && ...
                    consecutiveUnder > 15 || ...
                    consecutiveUnder > 45
                shouldResize = true;
            end
            consecutiveGood = 0;
        else
            % Assume this sample is good for now.  We'll set it to 0 later.
            consecutiveGood = this.ConsecutiveGood+1;
            this.ConsecutiveOver = 0;
            this.ConsecutiveUnder = 0;
        end
    end
    
    % If we've had 1000 total updates without an action, quarter all of the
    % statistics as a reset.  We do not want to get rid of all of the
    % statistics, just weight the new statistic more heavily.
    if updates > 1000
        this.Updates = this.Updates/4;
        this.OverRuns = this.OverRuns/4;
        this.UnderRuns = this.OverRuns/4;
    end
    
    % If we've had 100 consecutive good samples, reset everything.
    if consecutiveGood > 100
        this.Updates = 100;
        this.OverRuns = 0;
        this.UnderRuns = 0;
        consecutiveGood = 0;
    end
    this.ConsecutiveGood = consecutiveGood;
end

if shouldResize
    
    m = getPropValue(this, 'YDataDisplay')/100;
    
    % Perform calculation to get the preferred margin to the ylimits.
    % These calculations are based on these two equations.
    %
    %            ymin-newYLim(1)
    % margin = --------------------
    %          newYLim(2)-newYLim(1)
    %
    %            newYLim(2)-ymax
    % margin = --------------------
    %          newYLim(2)-newYLim(1)
    switch getPropValue(this, 'AutoscaleYAnchor')
        case 'Center'
            newYLim(1) = (ymin-ymax+m*ymax+m*ymin)/(2*m);
            newYLim(2) = (ymax-ymin+m*ymax+m*ymin)/(2*m);
            if ~force && expandOnly
                newYLim = [min(newYLim(1), currentYLim(1)) max(newYLim(2), currentYLim(2))];
            end
        case 'Top'
            
            newYLim(1) = (ymin-ymax+m*ymax)/m;
            newYLim(2) = ymax;
            
            if ~force && expandOnly
                newYLim(1) = min(newYLim(1), currentYLim(1));
            end
        case 'Bottom'
            newYLim(1) = ymin;
            newYLim(2) = ymin+(ymax-ymin)/m;
            if ~force && expandOnly
                newYLim(2) = max(newYLim(2), currentYLim(2));
            end
    end
    
    if newYLim(1) == newYLim(2)
        
        % Protect against YLim values being the same, which would result in
        % HG warnings.
        newYLim = [ymin-.5 ymax+.5];
    end
    
    % Reset all the counters.
    this.Updates = 0;
    this.OverRuns = 0;
    this.UnderRuns = 0;
    this.ConsecutiveOver = 0;
    this.ConsecutiveUnder = 0;
    this.ConsecutiveGood = 0;
    
    if this.AutoscaleXAxis
        
        % Make sure that the limits do not cause an error.
        if xmin == xmax
            xmin = xmin-.5;
            xmax = xmax+.5;
        end
        
        m = getPropValue(this, 'XDataDisplay')/100;
        
        % Reposition the data by changing the xlimits based on the x range
        % setting and where it should be justified.
        switch getPropValue(this, 'AutoscaleXAnchor')
            case 'Center'
                newXLim(1) = (xmin-xmax+m*xmax+m*xmin)/(2*m);
                newXLim(2) = (xmax-xmin+m*xmax+m*xmin)/(2*m);
            case 'Right'
                newXLim(1) = (xmin-xmax+m*xmax)/m;
                newXLim(2) = xmax;
            case 'Left'
                newXLim(1) = xmin;
                newXLim(2) = xmin+(xmax-xmin)/m;
                
        end
        set(hAxes, 'XLim', newXLim);
    end
    
    % Save these axes limits with the zoom, so that a "undo" on the zoom
    % will zoom out this far.
    set(hAxes, 'YLim', newYLim);
    
    % Capture the new Y-Limit as the maximum zoom out point.  This is
    % causing issues with static plots, remove for now.
%     resetplotview(hAxes, 'SaveCurrentView', 'YLim', 'YLimMode');
end

% [EOF]

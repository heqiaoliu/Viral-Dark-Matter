function propertyChanged(this, propName)
%PROPERTYCHANGED React to property value change events.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:27 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch propName
    case {'YDataDisplay' 'XDataDisplay' 'AutoscaleXAnchor' 'AutoscaleYAnchor'}
        
        % If we are in 'Auto' scale mode and the request range or anchor
        % changes, we want to force an autoscale.  This will cause the
        % property value to be immediately reflected in the display.
        if strcmp(getPropValue(this, 'AutoscaleMode'), 'Auto')
            performAutoscale(this, true);
        end
        
    case 'AutoscaleMode'
        
        % When 'Auto' is turn on, enable the listener so that we autoscale
        % at each time step.  Perform a quick autoscale regardless of the
        % over/under.
        
        % Fix the menu and button.
        hMgr = this.Application.getGUI;
        hAutoMenu = hMgr.findwidget('Base/Menus/Tools/ZoomAndAutoscale/Autoscale/EnableAutoscale');
        hStopMenu = hMgr.findwidget('Base/Menus/Tools/ZoomAndAutoscale/Autoscale/EnableOnceAtStop');
        
        set(hAutoMenu, 'Checked', 'off');
        set(hStopMenu, 'Checked', 'off');
        
        this.VisualUpdatedListener.Enabled = 'off';
        this.SourceStoppedListener.Enabled = 'off';
        
        switch getPropValue(this, 'AutoscaleMode')
            case 'Auto'
                set(hAutoMenu, 'Checked', 'on');
                performAutoscale(this, true);
                this.VisualUpdatedListener.Enabled = 'on';
                
                % When we are in "auto" mode, we also want to force an
                % update at the end.  It can look out of sync if we don't.
                this.SourceStoppedListener.Enabled = 'on';
            case 'Once at stop'
                set(hStopMenu, 'Checked', 'on');
                this.SourceStoppedListener.Enabled = 'on';
        end
    otherwise
        
        % Simply cache the value in the object for easier/faster access.
        this.(propName) = getPropValue(this, propName);
end

% [EOF]

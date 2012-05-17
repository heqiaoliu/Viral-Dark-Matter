function propertyChanged(this, eventData)
%PROPERTYCHANGED property change event handler

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:41:37 $

if ~(this.NTXFeaturedOn)
    if ischar(eventData)
        hProp = findProp(this, eventData);
    else
        hProp = get(eventData, 'AffectedObject');
    end
    value = get(hProp, 'Value');
    
    switch hProp.Name
      case 'ShowLegend'
        vis = logical2visible(value);
        cb_legendVisibility(this, vis);
        
        hUIMgr = this.Application.getGUI;
        hMenu = hUIMgr.findwidget('Menus', 'View','ShowLegend');
        set(hMenu, 'Checked', vis);
        
        % Set the state of this in the uicontextmenu 
        uim = get(get(this.Axes,'UIContextMenu'),'Children');
        set(uim,'Checked',vis); 
    end
end
% -------------------------------------------------------------------------
function visState = logical2visible(value)

if value
    visState = 'on';
else
    visState = 'off';
end

%-----------------------------------------------
function cb_legendVisibility(this, vis)

if ishghandle(this.Legend)
    % Make sure the legend is at least partly visible on the figure if it
    % was previously moved.
    
    % get the position of the legend.
    legend_pos = getpixelposition(this.Legend);
    
    % get the figure position to check if the legend is placed out of
    % bounds
    panel_pos = getpixelposition(get(this.Axes,'Parent'));
    
    if legend_pos(1)+legend_pos(3) > panel_pos(3) 
        legend_pos(1) = panel_pos(3)-legend_pos(3)-1;
    end
    if legend_pos(2)+legend_pos(4) > panel_pos(4)
        legend_pos(2) = panel_pos(4)-legend_pos(4)-1;
    end
    setpixelposition(this.Legend,legend_pos);
    set(this.Legend,'Visible',vis);
else
    % Set up the legend
    range_txt = uiscopes.message('lblHistogramRangeLegend');
    overflow_txt = uiscopes.message('lblHistogramOverflowLegend');
    underflow_txt = uiscopes.message('lblHistogramUnderflowLegend');
    
    set(this.LineHandleRe(1),{'DisplayName'},{range_txt});
    set(this.LineHandleRe(2),{'DisplayName'},{underflow_txt});
    set(this.LineHandleRe(3),{'DisplayName'},{overflow_txt});
    
    this.Legend = legend(this.Axes,'show');
    set(this.Legend,'Visible',vis);
    % Set the context menu of the legend to [] to prevent access to plotting
    % tools.
    set(this.Legend,'UIContextMenu',[]);
end

%-------------------------------------------------
% [EOF]

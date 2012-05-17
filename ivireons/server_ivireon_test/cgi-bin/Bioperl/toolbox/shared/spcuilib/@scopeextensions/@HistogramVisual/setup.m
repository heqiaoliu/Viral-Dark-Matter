function setup(this,hVisParent)
% SETUP Setup the visual.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $      $Date: 2010/03/31 18:41:40 $
    
setupAxes(this,hVisParent);

% Change the rendering mode on the figure to zbuffer so that zoom works
% correctly on patches within a uipanel.
set(this.Application.Parent,'renderer','zbuffer');

% Create NTX instead of the old visual if it is featured "On".
if this.NTXFeaturedOn
    initNTX(this, hVisParent);

    % Turn off the main toolbar on all platforms except the mac since we
    % don't have any buttons on the toolbar.
    if ~ismac
        UIExtension = this.Application.getExtInst('Core','General UI');
        UIExtension.findProp('ShowMainToolbar').Value = false;
    end
else
    % Setup axes for histogram. When drawmode is set to fast, it results in
    % faster rendering when the figure's Renderer property is set to painters.
    orig_units = get(this.Axes,'units');
    set(this.Axes,'units','pixels');
    pos = get(this.Axes,'position');
    pos(2) = pos(2)+12;
    pos(4) = pos(4)-12;
    set(this.Axes,'pos',pos);
    set(this.Axes,'units',orig_units);
    set(this.Axes,...
        'tag','HistogramAxes',...
        'parent',hVisParent,...
        'xdir','reverse',...
        'xlimmode','manual',...
        'TickDirMode','manual',...
        'TickDir','out',...
        'TickLength',[0.01 0.01],...
        'XTickLabel','',...
        'ylimmode','manual',...
        'drawmode','fast',...
        'ActivePositionProperty','OuterPosition'...
        );
    
    % Set the YTicks.
    set(this.Axes,'YLim',[0 100]);
    set(this.Axes,'YScale','Linear');
    
    % Set the X and Y axes labels.
    ylbl = uiscopes.message('lblHistogramYAxis');
    set(get(this.Axes,'YLabel'),'String',ylbl);
    
    % Add context menu to show and hide the legend
    uic = uicontextmenu('Parent',this.Application.Parent);
    uimenu(uic,'Label','Show Legend','Tag','HistogramLegendToggleCM','Checked','off','Callback',@(h,ev) toggleLegendVis(this,h));
    set(this.Axes,'UIContextMenu',uic);
    
    % Now click on line to select data point to use the update function
    this.YLimListener = uiservices.addlistener(this.Axes, 'YLim', ...
                                               'PostSet', @(h, ev) onYLimChange(this));
    
    this.XTickListener = uiservices.addlistener(this.Axes, 'XTick', ...
                                                'PostSet', @(h, ev) onXTickChange(this, ev));
    % react to resize events.
    set(hVisParent, 'ResizeFcn', @(hcbo, ev) locResize(this));
end
%--------------------------------------------------------------
function onYLimChange(this)
% respond to Y-limit changes.
ylim = get(this.Axes, 'YLim');

% If we're still zoomed out enough to show 4 ticks (0 10 20 30, 10 20 30
% 40, etc.) use those.  Otherwise just go back to the 'auto' mode.  We also
% need to make sure that we are still in the range (-10, 110) where we have
% ticks.
if ylim(2)-ylim(1) > 30 && ylim(2) < 110 && ylim(1) > -10
    ytick = ylim(1):10:ylim(2);
    set(this.Axes, 'YTick', ytick);
    set(this.Axes, 'YTickLabel', num2str(ytick'));
else
    set(this.Axes, 'YTickMode', 'auto', 'YTickLabelMode', 'auto');
end

% -------------------------------------------------------------------------
function onXTickChange(this, ev) %#ok
% Create customized x-tick labels and xlabels when the x-ticks change.

xtick = get(this.Axes,'XTick');
ylim = get(this.Axes,'YLim');
xLim = get(this.Axes,'XLim');
axes_vis = get(this.Axes,'Visible');
% Get the zoom object to have access to its state.
zoomObj = zoom(this.Application.Parent);
% If limits haven't changed don't re-create the ticks. If zoom is turned
% on, then always recreate the text widgets since we need to position them
% based on the X & Y limits.
if isequal(xLim,this.PreviousXLim) && strcmpi(zoomObj.Enable,'Off') ;return; end

this.PreviousXLim = xLim;
% The XLimits are manually set only when the zoom is disabled. Remove the
% buffer that was previously added to get the exact range at which we
% have data.
if strcmpi(zoomObj.Enable,'Off')
    act_range = xLim(1) + 0.5 : xLim(2) - 0.5;
else
    act_range = xLim(1)  : xLim(2);
end
% If the range is a vector or if the range is an integer, create the text
% labels. We do this because this callback gets fired many times as the
% xticks are being set. We don't want to waste time creating text objects
% when we don't have to.
if length(act_range) > 1 || isequal(act_range,floor(act_range))
    delete(this.XTicktextObj(ishghandle(this.XTicktextObj)));
    this.XTicktextObj = [];
    for i = 1:length(xtick)
        if ~isequal(floor(xtick(i)),ceil(xtick(i)))
            str = '';
        else
            str = sprintf('2^{%d}',round(xtick(i)));
        end
        % Use the min ylimit to position the text widget so that it moves along
        % with the YAxes as it is zoomed.
        ht = text('Parent',this.Axes,...
            'String',str,...
            'horiz','center','vert','top',...
            'units','data',...
            'pos',[xtick(i) ylim(1)],...
            'Visible',axes_vis...
            );
        
        orig_pos = get(ht,'pos');
        set(ht,'Units','char');
        pos = get(ht,'pos');
        pos(2) = pos(2)-0.5;
        set(ht,'pos',pos);
        set(ht,'Units','data');
        pos = get(ht,'pos');
        pos(1) = orig_pos(1);
        pos(3) = orig_pos(3);
        set(ht,'pos',pos);
        this.XTicktextObj(i) = ht;
    end
    
    tickPos = get(this.XTickTextObj(1),'Position');
    set(this.XTickTextObj(1),'Units','char');
    tickPosChar = get(this.XTickTextObj(1),'Position');
    set(this.XTickTextObj(1),'Units','data','pos',tickPos);
    %
    if ishghandle(this.xLabelTextObj); delete(this.xLabelTextObj); end
    this.xLabelTextObj = text('Parent',this.Axes,...
        'String',uiscopes.message('lblHistogramXAxis'),...
        'horiz','center','vert','top',...
        'pos',[0 ylim(1)],...
        'units','data',...
        'Visible',axes_vis,...
        'Tag','XLabel');
    xlim = get(this.Axes,'XLim');
    set(this.xLabelTextObj,'units','char');
    xLabelPosChar = get(this.xLabelTextObj,'pos');
    % Add one char spacing below.
    xLabelPosChar(2) = tickPosChar(2)-1.25;
    set(this.xLabelTextObj,'vert','top','pos',xLabelPosChar);
    set(this.xLabelTextObj,'units','data');
    xLabelPosData = get(this.xLabelTextObj,'Pos');
    xLabelPosData(1) = sum(xlim)/2;
    set(this.xLabelTextObj,'pos',xLabelPosData);
end
%--------------------------------------------------------------------------
function toggleLegendVis(this, menuObj)

if strcmpi(get(menuObj,'Checked'),'On')
    set(menuObj,'Checked','off');
    state = false;
else
    set(menuObj,'Checked','on');
    state = true;
end

%setPropValue does not trigger a propertyChanged event.
this.findProp('ShowLegend').Value = state;

% -------------------------------------------------------------------------
function locResize(this)
% Shut off the legend if the window is too small.

if ishghandle(this.Legend)
    axes_pos = get(this.Axes,'Position');
    legend_pos = get(this.Legend,'Position');
    % If the size of the axes window is smaller than the size of the legend,
    % hide the legend. If the legend takes up more than 80% of the axes
    % area, hide it. If the legend crosses the X/Y axes on resize,
    % reposition it so that it is within the axes.
    if (legend_pos(1) < axes_pos(1))
        pos = legend_pos;
        pos(1) = axes_pos(1)+0.02;
        set(this.legend,'Position',pos);
        legend_pos = get(this.legend,'Position');
    end
    if (legend_pos(2) < axes_pos(2))
        pos = legend_pos;
        pos(2) = axes_pos(2) + 0.02;
        set(this.legend,'Position',pos);
        legend_pos = get(this.legend,'Position');
    end
    if (legend_pos(1)+legend_pos(3) > axes_pos(1)+axes_pos(3))
        pos = legend_pos;
        pos_diff = (legend_pos(1)+legend_pos(3)) - (axes_pos(1)+axes_pos(3));
        pos(1) = legend_pos(1) - pos_diff - 0.01;
        set(this.legend,'Position',pos);
        legend_pos = get(this.legend,'Position');
    end
    if (legend_pos(2)+legend_pos(4) > axes_pos(2)+axes_pos(4))
        pos = legend_pos;
        pos_diff = (legend_pos(2)+legend_pos(4)) - (axes_pos(2)+axes_pos(4));
        pos(2) = legend_pos(2) - pos_diff - 0.01;
        set(this.legend,'Position',pos);
        legend_pos = get(this.legend,'Position');
    end
    if (legend_pos(3) > axes_pos(3)*4/5) || ...
            (legend_pos(4) > axes_pos(4)*4/5)
        this.findProp('ShowLegend').Value = false;
    end
end

% -------------------------------------------------------------------------
% [EOF]


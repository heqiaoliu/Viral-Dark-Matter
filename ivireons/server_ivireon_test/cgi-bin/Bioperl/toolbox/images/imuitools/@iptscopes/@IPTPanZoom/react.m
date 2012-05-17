function react(this)
%REACT    React to current zoom state

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/03/31 18:22:49 $

% Set toggle button states and menu checks appropriately
% Install 'zoom' functionality in figure

% Install cursor and functions
hSP  = this.ScrollPanel;
hVV  = this.Application.Visual;
hmgr = getGUI(this.Application);
if ~ishghandle(hSP) || isempty(hmgr) || strcmp(this.AppliedMode, this.Mode)
    return;
end
this.AppliedMode = this.Mode;
spAPI = iptgetapi(hSP);

hFig  = this.Application.Parent;
hAxes = get(hVV, 'Axes');

% Turn off warning for using imuitoolsgate
warnState = warning('off','Images:imuitoolsgate:undocumentedFunction');

hZoomIn  = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/ZoomIn');
hZoomOut = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/ZoomOut');
hPan     = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/Pan');
hFit     = hmgr.findchild('Base/Menus/Tools/Zoom/Mag/Maintain');

set(get(hZoomIn,  'WidgetHandle'), 'Checked', 'Off');
set(get(hZoomOut, 'WidgetHandle'), 'Checked', 'Off');
set(get(hPan,     'WidgetHandle'), 'Checked', 'Off');
set(get(hFit,     'WidgetHandle'), 'Checked', 'Off');

enab = 'On';
fun  = [];  % no operation
ptr  = setptr('arrow');

switch lower(this.Mode)
    case 'zoomin'
        % zoom-in mode
        fun = imuitoolsgate('FunctionHandle','imzoomin');  
        ptr = setptr('glassplus');
        
        set(get(hZoomIn, 'WidgetHandle'), 'Checked', 'On');
        
    case 'zoomout'
        % zoom-out mode
        fun = imuitoolsgate('FunctionHandle','imzoomout');    
        ptr = setptr('glassminus');

        set(get(hZoomOut, 'WidgetHandle'), 'Checked', 'On');
        
    case 'pan'
        % Panning mode.
        fun = imuitoolsgate('FunctionHandle','impan');  
        ptr = setptr('hand');

        set(get(hPan, 'WidgetHandle'), 'Checked', 'On');
        
    case 'fittoview'
        
        enab = 'off';
        
        % Fit to view.  We need to check if we are rendered here because
        % fit to view is the only mode that we remember in the
        % configuration/instrumentation set.
        if isRendered(hFit)
            set(get(hFit, 'WidgetHandle'), 'Checked', 'On');
        else
            oldWPs = get(hFit, 'WidgetProperties');
            set(hFit, 'WidgetProperties', {oldWPs{:}, 'Checked', 'On'});
        end
        
        % Set the magnification of the scroll panel to be the "fitmag"
        spAPI.setMagnification(spAPI.findFitMag());
end

% Set the enable state of the widgets based on the 
set([hZoomIn hZoomOut hPan], 'Enable', enab);
if usejava('awt')
    if isempty(this.Application.DataSource) || isDataEmpty(this.Application.DataSource)
        enab = 'off';
    end
    set(hmgr.findchild('Base/Toolbars/Main/Tools/Zoom/Mag/MagCombo'), 'Enable', enab);
end

% Setup the pointer manager.
if isempty(fun)
    % If there is no zoom function, clear pointer behavior from the axes.
    iptSetPointerBehavior(hAxes,[]);
else
    % If there is a navigation mode, set the axes' pointer behavior.
    iptSetPointerBehavior(hAxes, @(hFig, currentPoint) set(hFig, ptr{:}));
    iptPointerManager(hFig, 'enable');
end

% Install new zoom function.
spAPI.setImageButtonDownFcn(fun)

warning(warnState);

% [EOF]

function varargout = draw(this, varargin)
%DRAW Sets up the axis for drawing.
  
%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2010/05/20 03:10:43 $ 

fupdate = strcmpi(this.FastUpdate, 'Off');

if isa(this.OBDListener, 'handle.listener') || isa(this.OBDListener, 'event.listener')
    delete(this.OBDListener);
end

w = warning('off');

if fupdate,
    [wstr, wid] = lastwarn('');
    deletelineswithtag(this);
    
    % Set the zoomstate to none to restore the context menus before adding new
    % ones.
    setzoomstate(this.FigureHandle, 'none');
end

% Set the Axes specific properties
setaxesprops(this);

try
    if nargout,
        [varargout{1:nargout}] = thisdraw(this, varargin{:});
    else
        thisdraw(this, varargin{:});
    end
catch ME
    
    % If we error out, make sure we don't have any lines on the plot.
    h = get(this, 'Handles');
    for indx = 1:length(h.axes)
        delete(allchild(h.axes(indx)));
    end
    h.line = [];
    set(this, 'Handles', h);
    senderror(this, ME.identifier, ME.message);
end

if fupdate,
    
    formataxislimits(this);
    
    % Reset the axes zoom limits.  This will make zoom('out') return to the
    % current x and y lims.
    hAxes = this.Handles.axes;
    if length(hAxes) == 1
        zoom(hAxes, 'reset');
    end
    
    updatetitle(this);
    setlineprops(this);
    
    % Set the zoomstate back to the proper state to eliminate any contextmenus
    % if we are in a positive zoom state.
    setzoomstate(this.FigureHandle);
    
    sendwarning(this);
    lastwarn(wstr, wid);
    
    send(this, 'NewPlot', handle.EventData(this, 'NewPlot'));
    
    refresh(this.FigureHandle);
end

if ishandlefield(this, 'legend')
    hl = this.Handles.legend;
    
    % Remove the listener so that we don't turn off the Legend property by
    % deleting the legend.
    rmappdata(hl, 'OBD_Listener');
    delete(hl);
end
updatelegend(this);
updategrid(this);

warning(w);

% Create a listener on the 'ObjectBeingDestroyed' event of the 'key'
% handles.  When any of these handles are destroyed the entire object will
% unrender.
hKey = getkeyhandles(this);
for indx = 1:length(hKey)
    obdlistener(indx) = uiservices.addlistener(hKey(indx), ...
        'ObjectBeingDestroyed', @(h,ev) obd_listener(this));
end
this.OBDListener = obdlistener;

% ---------------------------------------------------------------------
function setaxesprops(this)
%SETAXESPROPS Set the Custom Axes properties since some of them are overridden 
% when drawing the response.

h  = get(this, 'Handles');
sz = gui_sizes(this);

% Gray used for Axes Color
col   = [.4,.4,.4];
props = {'XColor', col,...
        'YColor', col,...
        'fontsize', sz.fontsize, ...
        'Visible', this.Visible,...
        'Box', 'On'};
set(h.axes,props{:});

% Only turn on the grid for the first axes (for the Mag & Phase response), 
% so that the coincident grids will print and zoom correctly.
hax = getbottomaxes(this);

% Set the X & Y label properties
set([get(hax, 'Xlabel'), get(hax, 'Ylabel')], ...
    'FontSize', 8,...
    'Color', 'black');

% Set the ytickmode later to work around an HG issue.
set(h.axes, 'YTickMode', 'auto');

% ------------------------------------------------------------------
function obd_listener(h, eventData)

unrender(h);

% [EOF]

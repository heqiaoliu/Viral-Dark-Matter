function plot(this)
%PLOT   Plot the frequency response.
%     This method adds context menus to the x- and y-labels, adds menu
%     and context menu access to the analysis parameters dialog box, and
%     sets up the figure properties.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/07/28 04:38:00 $

% Make sure we reuse existing figures that have newplot set to reuse.
cax = newplot;
hFig = get(0, 'CurrentFigure');
set(hFig,'nextplot','replace');

render(this, cax);
%set(this,'legend','on');

% Add Signal Tbx menus and toolbar.
tagStr = 'SAP'; % Spectral Analysis Plot
if ~strcmpi(get(hFig,'Tag'),tagStr);
    setsptfigure(this,hFig);
    set(hFig,'Tag','SAP');  % Bread crumb to prevent calling setsptfigure.
end

% Add Analysis Parameter menu.
render_analysisparammenu(this,hFig,[2,6]);

% Install the context menu on the axis to access the analysis parameters.
add_cs_parameters(this);

set(this,'visible','on');
set(hFig, 'Visible', 'On');

% Set up a listener to listen to error and warning events. Gets destroyed
% when figure is "unrendered".
hlistener = handle.listener(this, 'Notification', @notification_listener);
this.WhenRenderedListeners = union(this.WhenRenderedListeners,hlistener);

%--------------------------------------------------------------------------
function notification_listener(hresp, eventData)
%NOTIFICATION_LISTENER Listener for error/warnings etc.

switch lower(eventData.NotificationType)
    case 'erroroccurred'
        err = get(eventData, 'Data');
        error(hresp,'Spectrum Analysis Error',err.ErrorString);
    
    case 'warningoccurred',
        warn = get(eventData, 'Data');
        warning(hresp,'Spectrum Analysis Warning',warn.WarningString);
end

%--------------------------------------------------------------------------
function [str,cb,tag,sep,accel] = analysisprm_menudescription(this)

str  = {xlate('Analysis Parameters...')};
cb   = {{@render_paramdlg,this}};
tag  = {'analysisparam'}; 
sep   = {'On'};
accel = {''};

%--------------------------------------------------------------------------
function hanalysisparammenu = render_analysisparammenu(this,hFig,position)
%RENDER_ANALYSISPARAMMENU Render the Analysis Parameter menu.

[str,cb,tag,sep,accel] = analysisprm_menudescription(this);

hm = findobj(findobj(hFig, 'type', 'uimenu', 'Position', position(1), ...
    'Parent', hFig), 'tag', tag{1});
if isempty(hm),
    hm = addmenu(hFig,position,str,cb,tag,sep,accel);
else
    set(hm, 'Callback', cb{1});    
end

% Store handles in order for them to be deleted when the plot is unrendered.
h = get(this, 'Handles');
h.menu.params.dlg = hm;
set(this, 'Handles', h);

%--------------------------------------------------------------------------
function render_paramdlg(hcbo, eventStruct,hObj)

h = hObj.setupparameterdlg;
set(h, 'Visible', 'On');
figure(h.FigureHandle);

%--------------------------------------------------------------------------
function add_cs_parameters(this)
%ADD_CS_PARAMETERS   Add a context sensitive menu to the axis.

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');

hc = uicontextmenu('Parent', hFig);
set(h.axes, 'UIContextMenu', hc);

[str,cb,tag,sep,accel] = analysisprm_menudescription(this);

h.menu.params.analysis = uimenu(hc, ...
    'Label', str{1}, ...
    'Callback', cb{1}, ...
    'Tag', [tag{1},'csmenu']);

% Save handles to CS objects in the handles structure so that it can be
% deleted properly.
h.menu.params.contextmenu = hc;
set(this, 'Handles', h);


% [EOF]

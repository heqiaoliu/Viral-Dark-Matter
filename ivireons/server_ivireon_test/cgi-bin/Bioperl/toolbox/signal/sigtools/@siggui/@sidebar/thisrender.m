function thisrender(this, hFig, varargin)
%RENDER Renders the Sidebar
%   RENDER Renders the sidebar object associated with this.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.9.4.14 $  $Date: 2009/01/05 18:01:02 $

error(nargchk(2,3,nargin,'struct'));

if ishghandle(hFig),
    render_sidebar(this, hFig);
else
    feval(hFig, this, varargin{:});
end


%----------------------------------------------------------
function render_sidebar(this, hFig)

sz      = sidebar_gui_sizes(this);
color   = get(0,'defaultuicontrolbackgroundcolor');
set(this, 'FigureHandle', hFig);

% Render the frame
h.frame = axes('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', sz.frame, ...
    'Visible', 'Off', ...
    'Color', color, ...
    'XTick', [], ...
    'YTick', [], ...
    'XTickLabel', [], ...
    'YTickLabel', [], ...
    'XLim', [0 1], ...
    'YLim',[0 1]);

h.line(1) = line([1 1],[0 1],'color','k','parent', h.frame, 'Visible', 'Off');  set(this, 'FigureHandle', hFig);
h.line(2) = line([0 0 1],[0 1 1],'color','w','parent', h.frame, 'Visible', 'Off');

set(h.frame,'Units','Normalized');
zoomBehavior = hggetbehavior(h.frame, 'Zoom');
zoomBehavior.Enable = false;
h.button = [];

set(this,'Handles',h);

% Install the panel_listener
% We do a PreSet listener so that we still have access to the old value
% This enables us to hide the old panel and show the new panel in the same listener
Listeners = handle.listener(this, this.findprop('CurrentPanel'),...
    'PropertyPreSet', @panel_listener);
set(Listeners,'CallbackTarget',this);

set(this,'WhenRenderedListeners',Listeners);

%----------------------------------------------------------
function renderselectionbutton(this, opts)
%RENDERSELECTIONBUTTON Render the selection button
%   RENDERSELECTIONBUTTON(this, OPTS) Renders the selection button to the
%   sidebar associated with this with the information contained within OPTS.

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');

if isfield(opts,'tooltip'),
    tooltip = opts.tooltip;
else
    tooltip = '';
end
if isfield(opts,'icon'),
    icon = opts.icon;
else
    icon = [];
end

pos = nextPos(this);

% Get the index to the new button
index = length(h.button)+1;

h.button(index) = uicontrol(hFig,...
    'style','togglebutton',...
    'position',pos,...
    'Visible', 'Off', ...
    'Interruptible', 'Off', ...
    'BusyAction', 'Queue', ...
    'callback',{@selector_cb,this,index},...
    'tooltip',tooltip,...
    'cdata',icon,...
    'tag','sidebar_button');

set(h.button(index),'Units','Normalized');

if isfield(opts, 'csh_tag'),
    fdaddcontextmenu(hFig, h.button(index), opts.csh_tag);
end
% end
set(this,'Handles',h);

% --------------------------------------------------------
function pos = nextPos(this)

sz = sidebar_gui_sizes(this);

h = get(this, 'Handles');
pos = sz.button;
pos(2) = pos(2)+pos(4)*length(h.button);
pos    = pos - [1 1 -1 1];

% --------------------------------------------------------
function sz = sidebar_gui_sizes(this)

sz = this.gui_sizes;

fx = 0*sz.pixf;
fy = 28*sz.pixf;
fw = 30*sz.pixf;
fh = 507*sz.pixf;

sz.frame  = [fx fy fw fh];
sz.button = [fx fy fw fw];

% --------------------------------------------------------
function selector_cb(hcbo, eventStruct, this, index)

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

% If the currently selected panel is not constructed, construct it
if isempty(getpanelhandle(this, index));
    constructAndSavePanel(this, index);
end

set(this, 'currentpanel', index);

set(hFig, p{:});

sendstatus(this, 'Ready');

% [EOF]

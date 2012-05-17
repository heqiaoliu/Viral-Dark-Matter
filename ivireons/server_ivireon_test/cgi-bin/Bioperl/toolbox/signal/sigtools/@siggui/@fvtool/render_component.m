function render_component(this, fcn, varargin)
%RENDER_COMPONENT Render FVTool's components.

% All of the render functions of fvtool are here as local functions 
% to save render time.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.36.4.25 $  $Date: 2009/07/14 04:03:35 $

feval(fcn, this, varargin{:});

%-------------------------------------------------------------------
function render_analysisparamsmenu(this, hp, sep)

error(nargchk(2,3,nargin,'struct'));
if nargin < 3, sep = 'On'; end

% Add a menu item to get at the analysis parameters
cbs = callbacks(this);

h = get(this, 'Handles');

if ~isfield(h, 'menu') || ~isfield(h.menu, 'params'),
    h.menu.params.analysis = []; h.menu.params.fs = []; h.menu.params.srr = [];
end

h.menu.params.analysis(end+1) = uimenu(hp, ...
    'Label', xlate('&Analysis Parameters ...'), ...
    'Callback', cbs.editparams, ...
    'Separator', sep, ...
    'Tag', 'fvtool_editanalysis');
h.menu.params.fs(end+1) = uimenu(hp, ...
    'Label', xlate('&Sampling Frequency ...'), ...
    'Callback', cbs.editfs, ...
    'Visible', this.FsEditable, ... 
    'Tag', 'fvtool_fs');

set(this, 'Handles', h);

% ----------------------------------------------------------------
function render_analysis_menu(this, position) %#ok
%RENDER_ANALYSIS_MENU Render an "Analysis" menu.

render_toplevel(this, position);
render_parameters(this);

% Loop over the tags and render the analysis submenu
info = get(this, 'AnalysesInfo');
tags = fieldnames(info);
for i = 1:length(tags)
    render_analysis_menuitem(this, tags{i});
end

% ----------------------------------------------------------------
function render_parameters(this)

h = get(this, 'Handles');

% We arent using addmenu here, because we would have to determine which
% menu is currently the analysis menu and determine where to place the
% menu items.  It's easier to just call UIMENU

hp  = h.menu.analysis;
cbs = callbacks(this);

h.menu.righthand.main = uimenu(hp, ...
    'Label', xlate('Overlay Analysis'), ...
    'Separator', 'On', ...
    'Callback', {@lclfix_submenu, this}, ...
    'tag', 'fvtool_righthandyaxis');
h.menu.righthand.none = uimenu(h.menu.righthand.main, ...
    'Label', xlate('(None)'), ...
    'tag', 'righthand_', ...
    'Checked', 'On', ...
    'Callback', cbs.righthand);

set(this, 'Handles', h);

render_analysisparamsmenu(this, hp);

% ----------------------------------------------------------------
function render_viewmenu(this, pos) %#ok

hFig = get(this, 'FigureHandle');
h    = get(this,'Handles');
cbs  = callbacks(this);

h.menu.view.main = findobj(hFig, 'type','uimenu','tag','view');

if isempty(h.menu.view.main),
    if nargin < 2,
        pos = length(findobj(hFig, 'type', 'uimenu', 'parent', hFig))+1;
    end
    h.menu.view.main = addmenu(hFig, pos, '&View', '', 'view', 'Off', '');
end

soscb = {cbs.method, this, 'sosview'};

lbls = {xlate('&Grid'), xlate('&Legend'), xlate('Specification &Mask'), ...
    xlate('User-defined Spectral Mask ...'), xlate('&Passband'), xlate('&Stopband')};
pos  = [0 0 0 0 repmat(length(allchild(h.menu.view.main)), 1, 2)]; 
chk  = {this.Grid, this.Legend, this.DisplayMask, 'Off', 'Off', 'Off'};
tags = {'grid', 'legend', 'displaymask', 'userdefinedmask', 'passband', 'stopband'};
cbs  = {{@checkmenu_cb, this}, {@checkmenu_cb, this}, {@checkmenu_cb, this}, ...
        {cbs.method, this, 'userdefinedmask'}, {cbs.method, this, @lclbandzoom, [], 'pass'}, ...
        {cbs.method, this, @lclbandzoom, [], 'stop'}};
sep  = {'Off', 'Off', 'Off', 'Off', 'On', 'Off'};

allowplugins = getappdata(hFig, 'allowplugins');
if isempty(allowplugins)
    allowplugins = true;
end

if allowplugins && isfdtbxinstalled,
    lbls = {lbls{1:4}, xlate('Show Reference Filter(s)'), ...
        xlate('Polyphase View'), lbls{5:6}, xlate('SOS View Settings ...')};
    pos  = [pos(1:4) 0 0 pos(5:6) pos(5)];
    chk  = {chk{1:4}, this.ShowReference, this.PolyphaseView, chk{5:6}, 'Off'};
    tags = {tags{1:4}, 'showreference', 'polyphaseview', tags{5:6}, 'sosview'};
    cbs  = {cbs{1:4}, cbs{1:2}, cbs{5:6}, soscb};
    sep  = {sep{1:4}, 'Off', 'Off', sep{5:6}, 'On'};
end

if ~isempty(allchild(h.menu.view.main))
    hfirst = findobj(h.menu.view.main, 'position', 1, 'parent', h.menu.view.main);
    set(hfirst, 'Separator', 'on');
end

for indx = 1:length(lbls),
    h.menu.view.(tags{indx}) = uimenu(h.menu.view.main, ...
        'Position', indx + pos(indx), ...
        'Label', lbls{indx}, ...
        'Tag', ['fvtool_' tags{indx}], ...
        'Checked', chk{indx}, ...
        'Callback', cbs{indx}, ...
        'Enable', 'On', ...
        'Separator', sep{indx});
end

set([h.menu.view.passband h.menu.view.stopband h.menu.view.displaymask], ...
    'Enable', 'Off');

set(this, 'Handles', h);


% ----------------------------------------------------------------
function render_toplevel(this, position)

hFig = get(this,'FigureHandle');
h    = get(this,'Handles');

% Render the Analysis menu items
h.menu.analysis = findobj(hFig, 'type', 'uimenu', 'tag', 'analysis');

% If there is no 'analysis' menu, create one.
if isempty(h.menu.analysis),
    h.menu.analysis = addmenu(hFig,position,xlate('&Analysis'),'','analysis','Off','');
%     drawnow; % Not sure why this is here
end

h.menu.analyses = [];

set(this,'Handles',h);


% ----------------------------------------------------------------
function render_analysis_menuitem(this, tag)
%RENDER_ANALYSIS_BUTTON Render an analysis button
%   RENDER_ANALYSIS_BUTTON(this, TAG) Render the analysis button associated
%   with the tag TAG.

% This can be private

% Get the handle information for rendering
h    = get(this, 'Handles');
cbs  = callbacks(this);

% Get the CData information
info = get(this,'AnalysesInfo');
info = info.(tag);

% If there is no label provided, don't render a menu.
if isempty(info.label), return; end

position = get(findobj(h.menu.analysis, 'tag', 'fvtool_righthandyaxis'), 'Position');

sep = 'off';
if position > 1 && isempty(h.menu.analyses), sep = 'on'; end

inputs = {'Label',info.label};

h.menu.analyses.(tag) = uimenu(inputs{:}, ...
    'Accelerator',info.accel, ...
    'Parent',   h.menu.analysis,...
    'Callback', cbs.analysis,...
    'Tag',      tag,...
    'Separator', sep, ...
    'Position',  position); % This position will make the buttons render in order.

if length(get(h.menu.righthand.main, 'Children')) == 1,
    sep = 'On';
else
    sep = 'Off';
end

h.menu.righthand.(tag) = uimenu(inputs{:}, ...
    'Parent',   h.menu.righthand.main, ...
    'Callback', cbs.righthand, ...
    'Tag',      sprintf('righthand_%s', tag), ...
    'Separator', sep);    

set(this, 'Handles', h);


% ----------------------------------------------------------------
function render_analysis_toolbar(this) %#ok
%RENDER_TOOLBAR Render the toolbar for FVTool.

% This can be private

% Loop over the tags and render the analysis toolbar
info = get(this, 'AnalysesInfo');
tags = fieldnames(info);
for i = 1:length(tags)
    render_analysis_button(this, tags{i});
end

% ----------------------------------------------------------------
function render_toolbar(this) %#ok
%RENDER_TOOLBAR Render the toolbar if none exists

h = get(this,'Handles');

hFig = get(this,'FigureHandle');

% Look for a toolbar to use.
aut = findall(hFig, 'type', 'uitoolbar', 'tag', 'analysistoolbar');
ut  = setdiff(findobj(hFig, 'type', 'uitoolbar'), aut);
if isempty(ut),
    
    % If a toolbar is not available, create one.
    ut = uitoolbar(hFig);
elseif length(ut) > 1,
    
    % If there is more than one toolbar, use the parent of the newanalysis
    % toggle button.
    ut = get(findall(ut, 'tag', 'newanalysis'), 'parent');
end
h.toolbar.analysis  = aut;
h.toolbar.figure    = ut;

set(this, 'Handles', h);

% ----------------------------------------------------------------
function render_analysis_button(this, tag)
%RENDER_ANALYSIS_BUTTON Render an analysis toolbar button

% This can be private

% Get the handle information for rendering
h     = get(this, 'Handles');
cbs   = callbacks(this);

% Get the CData information
info = get(this,'AnalysesInfo');
info = info.(tag);

% If no icon is given, do not render a toggle button
if isempty(info.icon), return; end

if ishghandle(h.toolbar.analysis),
    hut = h.toolbar.analysis;
else
    hut = h.toolbar.figure;
end

% Determine if there should be a separator
if ~(isempty(allchild(hut)) || isfield(h.toolbar, 'analyses')),
    sep = 'On';
else
    sep = 'Off';
end

h.toolbar.analyses.(tag) = uitoggletool('Cdata',info.icon, ...
    'Parent',          hut, ...
    'ClickedCallback', cbs.analysis, ...
    'Tag',             tag, ...
    'Separator',       sep, ...
    'Tooltipstring',   xlate([info.label(1) lower(info.label(2:end))]));

set(this, 'Handles', h);


% ----------------------------------------------------------------
function render_axes(this, pos) %#ok
%RENDER_AXES Render the axes for the FVTool

h    = get(this,'Handles');
hFig = get(this,'FigureHandle');

sigsetappdata(hFig, 'fvtool', 'handle', this);

defpos = get(0, 'DefaultAxesPosition');
defpos(3) = defpos(3)*.975;

% Create axes in the default position.
h.axes(2) = axes('Parent',hFig,...
    'Units','Normalized',...
    'Visible',this.Visible,...
    'ActivePositionProperty', 'position', ...
    'Position', defpos, ...
    'Tag','fvtool_axes_1');
h.axes(1) = axes('Parent',hFig,...
    'Units','Normalized',...
    'Visible',this.Visible,...
    'ActivePositionProperty', 'position', ...
    'Position', defpos, ...
    'HandleVisibility', 'Callback', ...
    'Tag','fvtool_axes_2');

% Link the yticks for the 2 axes, but not the ylimits.
setappdata(h.axes(2),'graphicsPlotyyPeer',h.axes(1));
setappdata(h.axes(1),'graphicsPlotyyPeer',h.axes(2));

h.listbox = uicontrol('Parent',hFig,...
    'Units','Pixels',...
    'Style','Listbox',...
    'Visible',this.Visible,...
    'Tag','fvtool_listbox',...
    'Backgroundcolor','w');

fdaddcontextmenu(hFig, h.listbox,'fdatool_filtercoefficients_viewer');

% If we have received a position use it.
if nargin == 2 && ~isempty(pos),
    set(h.axes, 'Units', 'Pixels', 'Position', pos);
    set(h.listbox, 'Position', pos);
else
    
    if ispc, fontname = 'MS Sans Serif';
    else     fontname = 'monospaced'; end
    
    % Make sure that the listbox is the same size as the axes.
    set(h.listbox, ...
        'FontName', fontname, ...
        'Units',    get(0, 'defaultaxesunits'), ...
        'Position', defpos);
end

set(this,'Handles',h);

hc = uicontextmenu('Parent', hFig);

set(h.axes, 'UIContextMenu', hc);

render_analysisparamsmenu(this, hc, 'Off');

% -------------------------------------------------------------------
function checkmenu_cb(hcbo, eventStruct, this) %#ok

prop = strrep(get(hcbo, 'tag'), 'fvtool_', '');

if strcmpi(get(this, prop), 'On'),
    check = 'off';
else
    check = 'on';
end
% Remove 'fvtool_' from the tag to get the property name.
set(this, prop, check);

% -------------------------------------------------------------------
function lclfix_submenu(hcbo, eventStruct, this) %#ok

% Needs to be a method to have access to private props.
fix_submenu(this);

% ------------------------------------------------------------------- 
function lclbandzoom(this, band) 
%LCLBANDZOOM zooms in on the passband or the stopband of the filter.

zoom(this, [band 'band']);

% [EOF]

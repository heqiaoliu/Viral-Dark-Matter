function this = fvtool(varargin)
%FVTOOL The constructor for the FVTool object.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.21.4.22 $  $Date: 2010/04/05 22:42:58 $

[varargin, analysisStr, optstruct, pvpairs, msg] = parse_inputs(varargin{:});
if ~isempty(msg),
    error(generatemsgid('invalidInputs'), msg);
end

this = sigtools.fvtool;

% Disable the NextPlot warning
[wstr, wid] = lastwarn('');
w = warning('off', 'MATLAB:HandleGraphics:SupersededProperty:NextPlotNew');

this.sigfig_construct('Visible', 'Off', ...
    'Menubar', 'None', ...
    'IntegerHandle', 'On', ...
    'NextPlot', 'New', ...
    'NumberTitle', 'On', ...
    'Tag', 'Initializing', ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'Name', 'Filter Visualization Tool', ...
    'HandleVisibility', 'On');

lastwarn(wstr, wid);
warning(w);

% Center the GUI
movegui(this.FigureHandle, 'center');

hFVT = siggui.fvtool;
addcomponent(this, hFVT);
addplugins(hFVT);

[filters, hasfs] = findfilters(this, varargin{:});
set(hFVT, 'Filters', filters);

alla = getallanalyses(hFVT);

enumName = 'fvtoolAnalyses';
f = findtype(enumName);
if isempty(f)
    schema.EnumType(enumName, alla);
else
    
    indx = 2;
    while ~isequal(f.Strings, alla)
        enumName = sprintf('fvtoolAnalyses%d', indx);
        f = findtype(enumName);
        if isempty(f)
            f = schema.EnumType(enumName, alla);
        end
        indx = indx+1;
    end
end

adddynprop(this, 'Analysis', enumName, {@setanalysis, 'Analysis'}, ...
    {@getanalysis, 'Analysis'});
adddynprop(this, 'OverlayedAnalysis', 'string', {@setanalysis, 'OverlayedAnalysis'}, ...
    {@getanalysis, 'OverlayedAnalysis'});

addplugins(this);

% Set the Current Analysis
set(hFVT, 'Analysis', analysisStr);
currentanalysis_listener(this);

if hasfs && isprop(this, 'NormalizedFrequency')
    set(this, 'NormalizedFrequency', 'off');
end

% Set all the inputs before rendering so that we only update once.

if ~isempty(optstruct),
    hFVT = getcomponent(this, 'fvtool');
    hPrm = get(hFVT, 'Parameters');
    struct2param(hPrm, optstruct);
end

% We have to attach the listeners first so that setting the analysis will
% update the dynamic properties.
attachlisteners(this);

% Make sure the properties are up to date.
currentanalysis_listener(this);

% Check the filter for FDESIGN to draw the masks.  Do this before setting
% the P/V Pairs in case the P/V pairs disable the mask.
Hd = get(this, 'Filters');
if isfdtbxinstalled
    
    if isa(Hd{1}, 'dfilt.basefilter')
        hfdfirst = privgetfdesign(Hd{1});
        hfmfirst = getfmethod(Hd{1});
    else
        hfdfirst = [];
        hfmfirst = [];
    end

    if isempty(hfdfirst) || isempty(hfmfirst), hasmask = false;
    else                                       hasmask = true; end

    % Loop over the rest of the filters, but break early if any of them
    % dont have a mask or it does not match the first.
    indx = 2;
    while indx <= length(Hd) && hasmask
        
        if isa(Hd{indx}, 'dfilt.basefilter')
            hfd = privgetfdesign(Hd{indx});
            hfm = getfmethod(Hd{indx});
        else
            hfd = [];
            hfm = [];
        end

        % If there is no fdesign or fmethod, or if they do not match the
        % first set, then we cannot draw a mask.
        if isempty(hfd) || isempty(hfm) || ...
                ~isequivalent(hfdfirst, hfd) || ...
                isconstrained(hfm) ~= isconstrained(hfmfirst)
            hasmask = false;
        end
        indx = indx + 1;
    end
    
    if hasmask
        pvpairs = [{'DesignMask', 'On'}, pvpairs];
    end
end

fdesignOptions = getFVToolOptions(this, filters);
pvpairs = [fdesignOptions, pvpairs];

% Set the param value pairs one at a time.
for indx = 1:length(pvpairs)/2
    set(this, pvpairs{2*indx-1:2*indx});
end

% Make sure the properties are up to date.
currentanalysis_listener(this);

% Render the toolbar
render_fvtool_toolbar(this);

% Render the Menus
render_fvtool_menus(this);

render(hFVT, this.FigureHandle);
setunits(hFVT,'Normalized');
set(hFVT, 'Visible', 'On');

render_viewmenuitems(this);

% Install Listeners
set(this, 'Tag', 'filtervisualizationtool');

lclnewplot_listener(this, []);

set(hFVT.CurrentAnalysis, 'Filters', get(hFVT, 'Filters'));

if desktop('-inuse')

    % MDI code
    
    mdiName = 'Filter Visualization Tool';
    
    % store the last warning thrown
    [ lastWarnMsg lastWarnId ] = lastwarn;

    % disable the warning when using the 'JavaFrame' property
    % this is a temporary solution
    oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jf = get(double(this),'JavaFrame');
    warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    % restore the last warning thrown
    lastwarn(lastWarnMsg, lastWarnId);
    
    jf.setGroupName(mdiName);
    
    % restore the last warning thrown
    lastwarn(lastWarnMsg, lastWarnId);
    
    set(this,'windowStyle','docked')
    hdesk = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
    if ~hdesk.isGroupShowing(mdiName)
        hdesk.setGroupDocked(mdiName, false);
    end
end

%-------------------------------------------------------------------
function attachlisteners(this)

hFVT  = getcomponent(this, 'fvtool');

hfig = this.FigureHandle;
addlistener(hfig, 'WindowStyle', 'PostSet', @(h, ev) onWindowStyleChange(this));
addlistener(hfig, 'ObjectChildAdded', @(h, ev) onChildAdded(ev));

l = [ ...
    handle.listener(hFVT, 'NewPlot', @lclnewplot_listener); ...
    handle.listener(this, this.findprop('HostName'), ...
    'PropertyPostSet', @lclhostname_listener); ...
    handle.listener(this,this.findprop('AnalysisToolbar'),...
    'PropertyPostSet', @lclanalysistoolbar_listener); ...
    handle.listener(this,this.findprop('FigureToolbar'),...
    'PropertyPostSet', @lclfiguretoolbar_listener); ...
    handle.listener(hFVT, [hFVT.findprop('Grid') hFVT.findprop('Legend')],...
    'PropertyPostSet', @lclonoff_listener); ...
    handle.listener(hFVT, hFVT.findprop('CurrentAnalysis'),...
    'PropertyPostSet', @currentanalysis_listener); ...
    handle.listener(hFVT, 'NewParameters', @currentanalysis_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', l);


%-------------------------------------------------------------------
function render_fvtool_menus(this)

hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

% Render the "File" menu
hmenus.hfile = render_filemenu(this, hFig);

% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(hFig);

% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(hFig,3);

h.menu.view = uimenu(hFig, 'Label', '&View', 'tag', 'view');

% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(hFig,5);
hmenus.hedit(end+1) = copyobj(hmenus.htools(2), hmenus.hedit(1));
set(hmenus.hedit(end), 'position', 1);
delete(hmenus.htools);

render_zoommenus(hFig, [get(h.menu.view, 'position') 1], 'defaultview');

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
render_helpmenu(hFig,6);

set(this, 'Handles', h);

%-------------------------------------------------------------------
function render_viewmenuitems(hFVT)

h = get(hFVT, 'Handles');

if length(allchild(h.menu.view(1))) > 1,
    sep = 'on';
else
    sep = 'off';
end

h.menu.view(end+1) = uimenu(h.menu.view(1), ...
    'Label', xlate('&Figure Toolbar'), ...
    'Checked', hFVT.FigureToolbar, ...
    'tag', 'fvtool_showfiguretoolbar', ...
    'Separator', sep, ...
    'Callback', {@lcltoolbar_cb, hFVT, 'figuretoolbar'});

h.menu.view(end+1) = uimenu(h.menu.view(1), ...
    'Label', xlate('&Analysis Toolbar'), ...
    'Checked', hFVT.AnalysisToolbar, ...
    'tag', 'fvtool_showanalysistoolbar', ...
    'Callback', {@lcltoolbar_cb, hFVT, 'analysistoolbar'});

set(hFVT, 'Handles', h);

%-------------------------------------------------------------------
function render_helpmenu(hFig, pos)

render_spthelpmenu(hFig, pos);
addmenu(hFig, [pos 1], xlate('FVTool Help'), @(h, ev) aboutfvtool_cb, 'fvtoolhelp');

%-------------------------------------------------------------------
function hfile = render_filemenu(this, hFig)

% Render the "File " menu
hfile = render_sptfilemenu(hFig);

% Add the "New Filter Analysis' menu item
strs  = 'New Filter Analysis';
cbs   = fvtool_cbs(this);
cbs   = {cbs.new_cb, this};
tags  = 'newanalysis'; 
sep   = 'off';
accel = 'N';
hnew = addmenu(hFig,[1 1],strs,cbs,tags,sep,accel);

set(findobj(hfile, 'tag', 'export'), 'Separator', 'On')

hfile = [hfile hnew];

%-------------------------------------------------------------------
function render_fvtool_toolbar(this)
%Render the toolbar 

h = get(this, 'Handles');

hFig = get(this, 'FigureHandle');
h.figuretoolbar = uitoolbar(hFig);

% Render the New Button
render_newbtn(this, h.figuretoolbar);

% Render Print buttons (Print, Print Preview)
render_sptprintbtns(h.figuretoolbar);

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
render_sptscribebtns(h.figuretoolbar);

% Render the zoom buttons
render_zoombtns(hFig);

% Render the Legend buton
cbs = fvtool_cbs(this);
h.toolbar.legend = render_legendonoffbtn(h.figuretoolbar, {cbs.legend_cb, this});
h.toolbar.grid   = render_gridonoffbtn(h.figuretoolbar, {cbs.grid_cb, this});
set(h.toolbar.legend, 'State', this.Legend);
set(h.toolbar.grid, 'Separator', 'Off', 'State', this.Grid);

h.analysistoolbar = uitoolbar(hFig, 'tag', 'analysistoolbar');

set(this, 'Handles', h);

%-------------------------------------------------------------------
function hnewbtn = render_newbtn(this, hut)

% Load new, open, save print and print preview icons.
load mwtoolbaricons;

pushbtns = newdoc;

tooltips = xlate('New Filter Analysis');

tags = 'newanalysis';

cbs = fvtool_cbs(this);     
btncbs = cbs.new_cb;
  
% Render the PushButton
hnewbtn = uipushtool('Cdata',pushbtns,...
    'Parent',         hut,...
    'ClickedCallback',{btncbs, this},...
    'Tag',            tags,...
    'Interruptible',  'Off', ...
    'BusyAction',     'cancel', ...
    'Tooltipstring',  tooltips);


%-------------------------------------------------------------------
function aboutfvtool_cb

helpview(fullfile(docroot, '/toolbox/signal/', 'signal.map'), 'fvtool_overview');


%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
%-------------------------------------------------------------------
function analysis = setanalysis(this, analysis, prop)

hfvt = getcomponent(this, 'fvtool');
set(hfvt, prop, analysis);

%-------------------------------------------------------------------
function analysis = getanalysis(this, analysis, prop) %#ok

hfvt = getcomponent(this, 'fvtool');
analysis = get(hfvt, prop);

%-------------------------------------------------------------------
%   Listeners
%-------------------------------------------------------------------

% -------------------------------------------------------------------
function onChildAdded(eventData)
%Set all legends invisible.

hSrc = eventData.Child;

if isa(hSrc, 'scribe.legend'),
    warning('MATLAB:legend:useMethod', '%s\n%s', ...
        'A legend has been added to FVTool without using the LEGEND method.', ...
        'Type help fvtool for more information.');
end

%-------------------------------------------------------------------
function lclnewplot_listener(this, eventData)

settitle(this);
send(this, 'NewPlot', eventData);

%-------------------------------------------------------------------
function onWindowStyleChange(this)

settitle(this);

%-------------------------------------------------------------------
function lclhostname_listener(this, eventData) %#ok

settitle(this);

%-------------------------------------------------------------------
function lclonoff_listener(this, eventData)

prop = get(eventData.Source, 'Name');
h = get(this, 'Handles');

if isempty(h)
    return;
end

set(h.toolbar.(lower(prop)), 'State', get(eventData, 'NewValue'));

%-------------------------------------------------------------------
function lclanalysistoolbar_listener(this, eventData) %#ok

h = get(this, 'Handles');

set(h.analysistoolbar, 'Visible', this.AnalysisToolbar);
set(findobj(h.menu.view, 'tag', 'fvtool_showanalysistoolbar'), ...
    'Checked', this.AnalysisToolbar);

%-------------------------------------------------------------------
function lclfiguretoolbar_listener(hFVT, eventData) %#ok

h = get(hFVT, 'Handles');

set(h.figuretoolbar, 'Visible', hFVT.FigureToolbar);
set(findobj(h.menu.view, 'tag', 'fvtool_showfiguretoolbar'), ...
    'Checked', hFVT.FigureToolbar);

%-------------------------------------------------------------------
function lcltoolbar_cb(hcbo, eventData, hFVT, prop) %#ok

at = get(hFVT, prop);

if strcmpi(at, 'off'), at = 'on';
else                   at = 'off'; end

set(hFVT, prop, at);

% -----------------------------------------------------
function options = getFVToolOptions(this, filters)

firstOptions = [];

% Loop over each of the filters and check its FDesign.
for indx = 1:length(filters)
    Hd = get(filters(indx), 'Filter');
    hfdesign = getfdesign(filters(indx).Filter);
    
    % If any of the filters do not have a contained FDesign, do not use any
    % options returned.
    if isempty(hfdesign)
        options = {};
        return;
    else
        
        % Get the options from the FDesign.
        options = getfvtoolinputs(hfdesign);
        if isempty(firstOptions)
            firstOptions = options;
        else
            
            % If the options do not match the first 
            if ~isequal(firstOptions, options)
                options = {};
                return;
            end
        end
    end
end

% Validate the options, if any fail, do not use any of them.
for indx = 1:2:length(options)
    if ~isprop(this, options{indx})
        options = {};
        return;
    end
end

% -----------------------------------------------------
function [varargin, analysisStr, optstruct, pvpairs, msg] = parse_inputs(varargin)
% Find the analysis string.  The rest is passed to the object

analysisStr = 'magnitude';
optstruct   = [];
pvpairs     = {};
msg         = '';

indx = 1;
while indx <= length(varargin) && isempty(pvpairs)
    if ischar(varargin{indx}),
        if indx == length(varargin),
            analysisStr = varargin{indx};
        elseif isstruct(varargin{indx+1}),
            analysisStr = varargin{indx};
            optstruct = varargin{indx+1};
        else
            pvpairs = varargin(indx:end);
            varargin = varargin(1:indx-1);
        end
    elseif isstruct(varargin{indx}),
        optstruct = varargin{indx};
    elseif isnumeric(varargin{indx}) || isa(varargin{indx}, 'qfilt') || ...
            isa(varargin{indx}, 'dfilt.basefilter') || ...
            isa(varargin{indx}, 'sigdatatypes.parameter') || ...
            isa(varargin{indx}, 'dfilt.dfiltwfs'),
        % NO OP.  These are the filters.
    elseif iscell(varargin{indx}),
        msg = 'FVTool does not accept cell arrays as inputs.';
    else
        msg = sprintf('FVTool does not accept %s as inputs.', class(varargin{indx}));
    end
    indx = indx + 1;
end

% [EOF]

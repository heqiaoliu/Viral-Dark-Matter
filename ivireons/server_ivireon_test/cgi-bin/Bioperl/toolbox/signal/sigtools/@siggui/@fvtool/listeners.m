function listeners(this, eventData, fcn, varargin)
%LISTENERS Returns a structure of function handles to FVTool's listeners.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.28.4.26 $  $Date: 2010/05/20 03:10:35 $

feval(fcn, this, eventData, varargin{:});

% --------------------------------------------------------------------
function analysis_listener(this, eventData)
%ANALYSIS_LISTENER Listener for the Current Analysis property

tag  = get(this, 'Analysis');

if isempty(tag),
    newa = [];

else

    % Get the new analysis object.
    sa = get(this, 'OverlayedAnalysis');
    if isempty(sa),
        newa = getanalysisobject(this);
    else
        try
            newa = buildtworesps(this);
        catch me
            set(this, 'OverlayedAnalysis', '');
            return; % Return because the OverlayedAnalysis listener will take care of this.
        end
    end
end

set(this, 'CurrentAnalysis', newa);

% Make sure that we check the correct string.  This wasn't being updated
% for Two Resps, because the listener wasn't being called.
if isrendered(this)
    h = get(this, 'Handles');
    set(convert2vector(h.menu.analyses), 'Checked', 'Off');
    set(convert2vector(h.toolbar.analyses), 'State', 'Off');
    if ~isempty(tag)
        set(h.menu.analyses.(tag), 'Checked', 'On');
        set(h.toolbar.analyses.(tag), 'State', 'On');
    end
end

set(this, 'SubMenuFixed', false);

sendfiltrespwarnings(this);

% --------------------------------------------------------------------
function secondanalysis_listener(this, eventData)

s = get(this, 'OverlayedAnalysis');
if isempty(s),
    analysis_listener(this, eventData);
    s = 'none';
else

    try
        
        % If we can build a tworesps with the 2nd response use it.
        ht = buildtworesps(this);
        set(this, 'CurrentAnalysis', ht);
    catch me
        
        % If we cannot ignore it.
        set(this, 'OverlayedAnalysis', '');
        analysis_listener(this, eventData);
        s = 'none';
    end
end

if isrendered(this)
    h  = get(this, 'Handles');

    set(h.menu.righthand.(s), 'Checked', 'On');
    set(convert2vector(rmfield(h.menu.righthand, s)), 'Checked', 'Off');
end

% Send the warnings once everything is done.
sendfiltrespwarnings(this);

% --------------------------------------------------------------------
function precurrentanalysis_listener(this, eventData)

ca = get(this, 'CurrentAnalysis');
h  = get(this, 'Handles');

sendstatus(this, 'Computing Response ...');

if ~isempty(ca),

    hdlg = get(this, 'ParameterDlg');
    rmcomponent(ca, hdlg);
    delete(ca.WhenRenderedListeners);
    unrender(ca);
end
set([h.axes h.listbox], 'Visible', 'Off');

set(convert2vector(h.menu.analyses), 'Checked', 'Off');
set(convert2vector(h.toolbar.analyses), 'State', 'Off');

% Set the DisplayMask now, because in the post listener we will not have
% the correct value.
newAnalysis = get(eventData, 'NewValue');
if isprop(newAnalysis, 'DisplayMask'), 
    set(newAnalysis, 'DisplayMask', this.DisplayMask);
end


% --------------------------------------------------------------------
function postcurrentanalysis_listener(this, eventData)

ca   = get(this, 'CurrentAnalysis');
h    = get(this, 'Handles');

tag = get(this, 'Analysis');

zoomBehavior1 = hggetbehavior(h.axes(1), 'Zoom');
zoomBehavior2 = hggetbehavior(h.axes(2), 'Zoom');

if isempty(tag)
    zoomBehavior1.Enable = false;
    zoomBehavior2.Enable = false;
    return;
end

zoomBehavior1.Enable = true;
zoomBehavior2.Enable = true;

% Check the current analysis
set(h.menu.analyses.(tag), 'Checked', 'On');
set(h.toolbar.analyses.(tag), 'State', 'On');

if isempty(ca),
    enabState = 'Off';
    l = [];
else
        
    l = [ ...
        handle.listener(ca, 'NewPlot', {@listeners, 'newplot_listener'}); ...
        handle.listener(ca, ca.findprop('Legend'), 'PropertyPostSet', ...
        @analysislegend_listener); ...
        ];
    set(l, 'CallbackTarget', this);

    % Sync up the filters
    set(ca, 'FastUpdate', this.FastUpdate, 'Filters', this.Filters, ...
        'ShowReference', this.ShowReference, 'PolyphaseView', this.PolyphaseView, ...
        'SOSViewOpts', this.SOSViewOpts);
    
    % Render the new analysis depending on what class it is.
    if isa(ca, 'sigresp.analysisaxis'),
        set(ca, 'Legend', this.Legend, 'Grid', this.Grid);
        if isprop(ca, 'UserDefinedMask'), set(ca, 'UserDefinedMask', this.UserDefinedMask); end
        render(ca, h.axes);
        enabState = 'On';
    elseif isa(ca, 'sigresp.listboxanalysis'),
        render(ca, h.listbox);
        enabState = 'Off';
    else
        render(ca, [h.axes, h.listbox]);
        enabState = 'Off';
    end

    % Sync up the filters
    set(ca, 'Visible', this.Visible);
end

% Set up the parameter dialog.
hdlg = get(this, 'ParameterDlg');
if ~isempty(hdlg),
    
    if isempty(ca),
        set(hdlg, 'Parameters', [], 'Label', 'Analysis Parameters');
    else
        if isrendered(hdlg),
            setupparameterdlg(ca, hdlg);
            cshelpcontextmenu(hdlg.FigureHandle, handles2vector(hdlg), ...
                'fvtool_analysis_parameters', 'FDATool');
        end
    end
end

% Disable the grid/legend menu items if the analysis object does not use
% usesaxes.
hview = h.menu.view;
he = [hview.grid, hview.legend];
set(he, 'Enable', enabState);

set(this, 'CurrentAnalysisListener', l);

displaymask_listener(this, eventData);

sendstatus(this, 'Computing Response ... done');

sendfiltrespwarnings(this);
updatezoommenus(this);

% --------------------------------------------------------------------
function filter_listener(this, eventData) %#ok

% Get the analysis info that contains the check function.
aInfo = get(this, 'AnalysesInfo');
fn = fieldnames(aInfo);
fn = setdiff(fn, 'tworesps'); % Remove tworesps
h = get(this, 'Handles');

% Loop over each analysis and check that the filters are valid.
for indx = 1:length(fn)
    if ~isempty(aInfo.(fn{indx}).check) && ~feval(aInfo.(fn{indx}).check, this.Filters);
        
        % Disable the menu and toolbars if the analysis isn't valid.
        set([h.toolbar.analyses.(fn{indx}) h.menu.analyses.(fn{indx})], 'Enable', 'Off');

        % If we are on an invalid analysis go back to magnitude.
        if strcmpi(this.Analysis, fn{indx})
            set(this, 'Analysis', 'magnitude');
        end
    else
        set([h.toolbar.analyses.(fn{indx}) h.menu.analyses.(fn{indx})], 'Enable', 'On');
    end
end

set(this, 'SubMenuFixed', false);
fix_submenu(this);

% --------------------------------------------------------------------
function analysislegend_listener(this, eventData)

set(this, 'Legend', get(this.CurrentAnalysis, 'Legend'));

% --------------------------------------------------------------------
function show_listener(this, eventData)

h = get(this, 'Handles');

% This should never change when the handle doesn't exist.

set(h.menu.view.showreference, 'Checked', get(this, 'ShowReference'));
set(h.menu.view.polyphaseview, 'Checked', get(this, 'PolyphaseView'));

% --------------------------------------------------------------------
function newanalysis_eventcb(this, eventData)

% This is a WhenRenderedListener

tag = eventData.Data;

% Render the new button and menuitem
render_component(this, 'render_analysis_button', tag);
render_component(this, 'render_analysis_menuitem', tag);

% --------------------------------------------------------------------
function newplot_listener(this, eventData)

displaymask_listener(this, eventData)
updatezoommenus(this);
send(this, 'NewPlot', eventData);

% --------------------------------------------------------------------
function displaymask_listener(this, eventData)

ha = get(this, 'CurrentAnalysis');
h  = get(this, 'Handles');

if isempty(ha) || ~enablemask(ha),
    enabState = 'Off';
    checked   = 'Off';
else
    enabState = 'On';
    checked   = this.DisplayMask;
end

set(h.menu.view.displaymask, 'Enable', enabState, 'Checked', checked);

% -------------------------------------------------------------------
function legend_listener(this, eventData)

h = get(this, 'Handles');

visState = get(this,'Legend');

% Change the state of the legend toggle button
if isfield(h.toolbar, 'legend'),
    set(h.toolbar.legend,'State',visState);
end
set(h.menu.view.legend, 'Checked', visState);

% -------------------------------------------------------------------
function grid_listener(this, eventData)

grid = get(this, 'Grid'); 

h = get(this, 'Handles'); 

set(h.menu.view.grid, 'Checked', grid); 

if isfield(h.toolbar, 'grid'), 
    set(h.toolbar.grid, 'State', grid); 
end 

% -------------------------------------------------------------------
function fseditable_listener(this, eventData)

fse = get(this, 'FsEditable');

h = get(this, 'Handles');

hfs = h.menu.params.fs;

set(hfs(ishghandle(hfs)), 'Visible', fse);

hdlg = getcomponent(this, '-class', 'siggui.dfiltwfsdlg');
if ~isempty(h),
    set(hdlg, 'Enable', fse, 'Filters', get(this, 'Filter'));
end

% -------------------------------------------------------------------
function axesgrid_listener(this, eventData)

set(this, 'Grid', get(eventData.AffectedObject, eventData.Source.Name));

% -------------------------------------------------------------------
function ht = buildtworesps(this)
%Build the two responses object for the 2nd analysis.

f = get(this, 'Analysis');
s = get(this, 'OverlayedAnalysis');

ht    = getanalysisobject(this, 'tworesps');
ha    = getanalysisobject(this, f, 'new');
ha(2) = getanalysisobject(this, s, 'new', getxaxisparams(ha));
    
set(ht, 'Analyses', ha);

% -------------------------------------------------------------------
function updatezoommenus(this, varargin)

ca = get(this, 'CurrentAnalysis');

passEnab = 'Off';
stopEnab = 'Off';

if ~isempty(ca)
    Hd = get(ca.Filters, 'Filter');
    if iscell(Hd)
        Hd = [Hd{:}];
    end
    if isempty(Hd)
        x = nan;
        y = nan;
    else
        for indx = 1:length(Hd)
            hdesign = getfdesign(Hd(indx));
            hmethod = getfmethod(Hd(indx));
            if isempty(hdesign) || isempty(hmethod)
                x = nan;
                y = nan;
            elseif ~haspassbandzoom(hdesign)
                x = nan;
                y = nan;
            else
                x = 1;
                y = 1;
            end
        end
    end
    if ~any([isnan(x) isnan(y)]) && isa(ca, 'filtresp.magnitude')
        passEnab = 'On';
    elseif enablemask(ca) && length(Hd) == 1 && isprop(Hd, 'MaskInfo'),
        mi = get(Hd, 'MaskInfo');
        bands = mi.bands;
        for indx = 1:length(bands)

            if isfield(bands{indx}, 'magfcn')
                switch bands{indx}.magfcn
                    case {'cpass', 'pass', 'wpass'}
                        passEnab = 'On';
                    case {'wstop', 'stop'}
                        stopEnab = 'On';
                end
            end
        end
    end
end

h = get(this, 'Handles');

set(h.menu.view.passband, 'Enable', passEnab);
set(h.menu.view.stopband, 'Enable', stopEnab);

% [EOF]

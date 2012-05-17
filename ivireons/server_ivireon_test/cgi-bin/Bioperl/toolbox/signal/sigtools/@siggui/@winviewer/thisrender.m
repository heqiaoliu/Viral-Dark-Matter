function thisrender(this, hFig, pos, index)
%THISRENDER Render the window viewer component

%   Author(s): V.Pellissier
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.8 $  $Date: 2009/04/21 04:36:55 $

if nargin < 4, index = 2; end
if nargin < 3, pos   = []; end
if nargin < 2, hFig  = gcf; end

sz = gui_sizes(this);
if isempty(pos)
    pos = [10 10 659 320]*sz.pixf;
end

hPanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'Visible', 'Off', ...
    'Title', xlate('Window Viewer'));

hLayout = siglayout.gridbaglayout(hPanel);

set(hLayout, ...
    'HorizontalGap', 5, ...
    'VerticalGap', 5, ...
    'VerticalWeights', [1 0]);

hc = uicontainer('Parent', hPanel);

hLayout.add(hc, 1, 1:3, ...
    'Fill', 'Both', ...
    'TopInset', 10*sz.pixf);

% Time Domain
h.axes.td = axes('parent', hc, ...
    'box', 'on', ...
    'Color', 'White', ...
    'FontSize', sz.fontsize, ...
    'tag', 'timedomain', ...
    'xgrid', 'on', ...
    'ygrid', 'on', ...
    'xcolor', [0.4  0.4 0.4], ...
    'ycolor', [0.4  0.4 0.4]);

% Frequency domain
h.axes.fd = axes('parent', hc, ...
    'box', 'on', ...
    'Color', 'White', ...
    'FontSize', sz.fontsize, ...
    'tag', 'freqdomain', ...
    'xgrid', 'on', ...
    'ygrid', 'on', ...
    'xcolor', [0.4  0.4 0.4], ...
    'ycolor', [0.4  0.4 0.4]);

% XLabels
h.axes.tdxlabel = get(h.axes.td,'XLabel');
h.axes.fdxlabel = get(h.axes.fd,'XLabel');

% YLabels
h.axes.tdylabel = get(h.axes.td,'YLabel');
h.axes.fdylabel = get(h.axes.fd,'YLabel');
% Need to initialize YLabel to create a contextmenu using addunitsmenu
p  = getparameter(this, 'magnitude');
set(h.axes.fdylabel, 'String', xlate(p.Value));

% Titles
h.axes.tdtitle = get(h.axes.td, 'Title');
set(h.axes.tdtitle, 'String', xlate('Time domain'));
h.axes.fdtitle = get(h.axes.fd, 'Title');
set(h.axes.fdtitle, 'String', xlate('Frequency domain'));

% Set graphical properties of xlabels and titles
set([h.axes.tdxlabel ...
    h.axes.fdxlabel ...
    h.axes.tdylabel ...
    h.axes.fdylabel ...
    h.axes.tdtitle ...
    h.axes.fdtitle], ...
    'FontSize', sz.fontsize, 'Color', 'Black')

% Define the strings
Str = {'Leakage Factor: ', ...
    'Relative sidelobe attenuation: ', ...
    'Mainlobe width (-3dB): '};

for indx = 1:3,
    h.text(indx) = uicontrol(hPanel, ...
        'style',               'text', ...
        'ForegroundColor',     [0.4  0.4 0.4], ...
        'Enable',              'on', ...
        'horizontalAlignment', 'center', ...
        'string',              Str{indx}, ...
        'tag',                 'measurements');

    hLayout.add(h.text(indx), 2, indx, ...
        'Fill', 'Horizontal', ...
        'MinimumHeight', sz.uh);
end

% Add the menus
hMag = getparameter(this, 'magnitude');
hcontextmenu = contextmenu(hMag, h.axes.fdylabel);
h.frespunits = get(hcontextmenu, 'Children');

[hfdcontextmenu hfdmenus] = addfreqcsmenu(this, h.axes.fdxlabel);
[htdcontextmenu htdmenus] = addtimecsmenu(this, h.axes.tdxlabel);

cb = callbacks(this);
hfreqspecs = uimenu(hfdcontextmenu, ...
    'Label', xlate('Analysis Parameters ...'), ...
    'Callback', cb.analysisparam, ...
    'Separator', 'on');
set(h.axes.fdxlabel, 'UIContextMenu', hfdcontextmenu);

hfreqspecs = uimenu(htdcontextmenu, ...
    'Label', xlate('Analysis Parameters ...'), ...
    'Callback', cb.analysisparam, ...
    'Separator', 'on');
set(h.axes.tdxlabel, 'UIContextMenu', htdcontextmenu);

% Add a listener on the Frequency Display Parameter to control 
% the Range and Sampling parameters
freqmode = getparameter(this, 'freqmode');
l = handle.listener(freqmode, 'UserModified', @freqmodemodified_eventcb);
l(2) = handle.listener(freqmode, freqmode.findprop('Value'), ...
    'PropertyPostSet', @freqmodemodified_eventcb);
freqmodemodified_eventcb(this, [])

% Add a listener on the Frequency Display Parameter to update 
% the checked status of the context menus
freqmode = getparameter(this, 'freqmode');
l(3) = handle.listener(freqmode, freqmode.findprop('Value'), ...
    'PropertyPostSet', @freqmodenewvalue_eventcb);

set(l, 'CallbackTarget', this);
setappdata(hFig, 'freqmode_listener', l);


% Add a listener on the Sampling Frequency Parameter to update 
% Fs value in the context menu item
sampfreq = getparameter(this, 'sampfreq');
l = handle.listener(sampfreq, sampfreq.findprop('Value'), ...
    'PropertyPostSet', @sampfreqmodified_eventcb);
set(l, 'CallbackTarget', this);
setappdata(hFig, 'sampfreq_listener', l);

h.freqspecs = [hfdmenus htdmenus];

% Get the View menu parameters.
[strs,cbs,tags,sep,accel] = getviewparams(this);    

% Render the context menu items
thiscontextmenu = uicontextmenu('parent', hFig);
N = length(strs);
for i=1:N,
    h.contextmenu(i) = uimenu(thiscontextmenu, ...
        'Label', strs{i}, ...
        'Callback', cbs{i}, ...
        'Tag', tags{i}, ...
        'Separator', sep{i}, ...
        'Accelerator', accel{i});
end

% Add context-sensitve help
tag = ['WT?wintool_winviewer_frame'];
toolname = 'WinTool';
h.contextmenu(N+1) = uimenu(thiscontextmenu, ...
    'Label', '"What''s This?"',...
	'Callback', {@cshelpengine,toolname,tag}, ...
	'Separator', 'on', ...
	'Tag', tag);

set([hc hPanel], 'UIContextMenu', thiscontextmenu);

% Get the View menu parameters.
[strs,cbs,tags,sep,accel] = getviewparams(this);
% Add a 'View' root
strs  = [{xlate('V&iew')} strs];
cbs   = [{''} cbs];
tags  = [{'view'} tags];
sep   = [{'Off'} sep];
accel = [{'I'} accel];

% Render the View menu items
h.menu = addmenu(hFig,index,strs,cbs,tags,sep,accel);

% Add the legend toggle button
hparent = findall(ancestor(hFig, 'figure'),'Type','uitoolbar');
if isempty(hparent),
    hparent = uitoolbar('Parent', ancestor(hFig, 'figure'));
end
 
% Structure of all local callback functions
cbs = callbacks(this);     

h.legendbtn = render_legendonoffbtn(hparent, '', cbs.legend_on, cbs.legend_off);

% Create the listeners
listener    = handle.listener(this, [this.findprop('Timedomain') ...
    this.findprop('Freqdomain')], 'PropertyPostSet', @timefreq_listener);
listener(2)    = handle.listener(this, this.findprop('Legend'), ...
    'PropertyPostSet', @legend_listener);
hPrms = get(this, 'Parameters');
listener(3) = handle.listener(hPrms, 'NewValue', @update_viewer);

% Set this to be the input argument to these listeners
set(listener,'CallbackTarget', this);

% Save the listeners
set(this, ...
    'WhenRenderedListeners', listener, ...
    'Handles', h, ...
    'FigureHandle', hFig, ...
    'Container', hPanel);

% Add context-sensitive help
cshelpcontextmenu(hFig, h.text, ...
    'wintool_winviewer_frame', 'WinTool');
cshelpcontextmenu(hFig, [h.axes.td, h.axes.fd], ...
    'wintool_winviewer_frame', 'WinTool');

% Fire timefreq_listener
timefreq_listener(this);


% -----------------------------------------------------------
function freqmodemodified_eventcb(this, eventData)

hDlg = get(this, 'ParameterDlg');

if isfield(get(eventData), 'Data'),
    value = eventData.Data;
else
    hPrm = getparameter(this, 'freqmode');
    value = hPrm.Value;
end

if strcmpi(value, 'normalized'),
    opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
else
    opts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
end  

if ~isempty(hDlg),
    
    if strcmpi(value, 'normalized'),
        % Disable Sampling
        disableparameter(hDlg, 'sampfreq');
    else
        % Enable Sampling
        enableparameter(hDlg, 'sampfreq');
    end  
    
end

% Set valid values of Range
setvalidvalues(getparameter(this, 'unitcircle'), opts);
    


% -----------------------------------------------------------
function freqmodenewvalue_eventcb(this, eventData)

hndls = get(this, 'Handles');
set(hndls.freqspecs, 'Checked', 'off');

hPrm = getparameter(this, 'freqmode');
value = hPrm.Value;

% Update the checked status of the menu items
if strcmpi(value, 'normalized'),
    set(hndls.freqspecs([1 3]), 'Checked', 'on');
else
    set(hndls.freqspecs([2 4]), 'Checked', 'on');
end


% -----------------------------------------------------------
function sampfreqmodified_eventcb(this, eventData)

% Update Fs value in the context menu item
hndls = get(this, 'Handles');
[fs xunits multiplier] = getfs(this, 1);
set(hndls.freqspecs(2), 'Label', ...
    ['Linear Frequency (Fs = ' num2str(fs) xunits ')']); 

%--------------------------------------------------------------------------
function [strs,cbs,tags,sep,accel] = getviewparams(this)
% Get the "View" menu parameters. 

% Get the View menu labels
strs = {xlate('Time domain'), ...
        xlate('Frequency domain'), ...
        xlate('Legend'), ...
        xlate('Analysis Parameters...')};

% Define the CallBacks
cb = callbacks(this);
cbs = {cb.set_timedomain, ...
       cb.set_freqdomain, ...
       cb.legend, ...
       cb.analysisparam};

% Get the Tags
tags = {'timedomain', ...
        'freqdomain', ...
        'legendmenu', ...
        'frequnits'};

% Get the Separator flags
sep = {'Off', 'Off', 'On', 'On'};

% Get the Accelerators
accel = {'', '', '', '', ''};

% [EOF]

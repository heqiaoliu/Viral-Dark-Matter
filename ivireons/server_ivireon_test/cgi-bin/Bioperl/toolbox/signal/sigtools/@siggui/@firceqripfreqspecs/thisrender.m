function thisrender(this, varargin)
%RENDER  Render the freqmagspecs frame and all associated uicontrols
%   RENDER(H, HFIG, POS)
%   H   -   Handle to freqmagspecs object
%   HFIG-   Handle to figure into which to render
%   POS -   Position at which the frame should be rendered

%   Author(s): Z. Mecklai
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.7 $  $Date: 2009/03/09 19:35:32 $

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freq' ; end

% Call the super classes render method
super_render(this, pos);

sz   = gui_sizes(this);
pos  = getpixelpos(this, 'framewlabel', 1);
hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

% Add a listener to the fsspecifier units property
fsh = getcomponent(this, 'siggui.specsfsspecifier');

% Render the FSSpecifier
render(fsh, hFig, pos);

% Get the name of the frequency prperty
Name = getdynamicname(this);

% Render the radio buttons
h.rbs_handles = render_popup(this, sz, fsh);
h.freq_handles = render_passstop_freq(this, sz, fsh, Name);
% handles.fs = get(fsh, 'handles');

% Complete the rest of the data management and listener installations
completerender(this, h, Name);

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_freq_specs_frame');


%-------------------------------------------------------------------------------
function completerender(this, handles, Name)

% Store the handle structure
set(this, 'handles', handles);

% install listeners

% Extract listener
listeners = this.WhenRenderedListeners;

listeners(end+1) = handle.listener(this, ...
    this.findprop('freqSpecType'), ...
    'PropertyPostSet', @FreqOpts_listener);

listeners(end+1) = handle.listener(this, ...
    this.findprop(Name), ...
    'PropertyPostSet', @Frequency_listener);

set(listeners, 'callbacktarget',this);


% Install listeners
set(this, 'WhenRenderedListeners', listeners)

% Resize the FS label
fs_handles = handles.freq_handles(1);
position = get(fs_handles, 'position');
strings = {'Fc:','Fpass:','Fstop:'};
position(3) = largestuiwidth(strings);
set(fs_handles,'units','pixels');
set(fs_handles, 'position', position);
set(fs_handles,'units','normalized');

set(fs_handles, 'string', [Name,':']);

%-------------------------------------------------------------------------------
function popup_handles = render_popup(this, sz, fsh)
%RENDER_RADIO_BUTTONS  Render the radio buttons

labels = {'cutoff','passband edge','stopband edge'};

setunits(fsh, 'pixels');
handles = get(fsh, 'handles');
lblPos = get(handles.value_lbl, 'Position');
lblPos(2) = lblPos(2) - 1*(sz.uh + sz.uuvs);
lblPos(3) = largestuiwidth({'Specify:'});
ebPos = get(handles.value, 'Position');
ebPos(2) = ebPos(2) - 1*(sz.uh + sz.uuvs);
setunits(fsh, 'normalized');

popup_handles(1) = uicontrol('Style','Text',...
    'Visible','off',...
    'Enable','on',...
    'String', 'Specify:',...
    'HorizontalAlignment','left',...
    'Units','pixels',...
    'Position',lblPos);

popup_handles(2) = uicontrol('Style','popup',...
    'Visible','off',...
    'Enable','on',...
    'Backgroundcolor','w',...
    'String', labels,...
    'callback',{@popup_callback, this},...
    'Units','pixels',...
    'Position', ebPos);


CurrOpt = get(this, 'freqSpecType');
AllOpts = set(this, 'freqSpecType');

I = find(strcmp(AllOpts, CurrOpt));

set(popup_handles(2), 'value', I);


%-------------------------------------------------------------------------------
function popup_callback(hSource, eventdata, this) %#ok<INUSL>
%RBS_CALLBACK  Callback for the radio buttons

% Get the index
I = get(hSource, 'Value');

% Turn the radio button selected on
set(hSource, 'value', I);

% Set the option to the one selected from the radio button
AllOpts = set(this, 'freqSpecType');

set(this, 'freqSpecType', AllOpts{I});
% Send event
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

%-------------------------------------------------------------------------------
function freq_handles = render_passstop_freq(this, sz, fsh, Name)
%RENDER_PASSSTOP_FREQ  Render the label and edit box for the passband/stopband freq

setunits(fsh, 'pixels');
handles = get(fsh, 'handles');
lblPos = get(handles.value_lbl, 'Position');
lblPos(2) = lblPos(2) - 2*(sz.uh + sz.uuvs);
ebPos = get(handles.value, 'Position');
ebPos(2) = ebPos(2) - 2*(sz.uh + sz.uuvs);
setunits(fsh, 'normalized');

freq_handles(1) = uicontrol('style','text',...
    'visible','off',...
    'enable','on',...
    'units','pixels',...
    'position', lblPos,...
    'horizontalalignment', 'left');

freq_handles(2) = uicontrol('style','edit',...
    'visible','off',...
    'enable','on',...
    'units','pixels',...
    'position',ebPos,...
    'horizontalalignment','left',...
    'string', get(this, Name),...
    'callback', {@Frequency_callback, this},...
    'backgroundcolor','w');

setenableprop(freq_handles, 'on');

%-------------------------------------------------------------------------------
function Frequency_callback(hSource, eventData, this) %#ok<INUSL>
%FREQUENCY_CALLBACK  Callback for the passband/stopband frequency edit box

% Get the name of the frequency prperty
Name = getdynamicname(this);

% Fix up the edit box and get the string entered
strs = fixup_uiedit(hSource);

% Set the frequency property
set(this, Name, strs{1});

% Send event
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% [EOF]

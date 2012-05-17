function thisrender(this)
%THISRENDER   Render the dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/08/29 08:32:07 $

cbs = siggui_cbs(this);
sz  = gui_sizes(this);

% Put up the dialog's figure.
figw = 375*sz.pixf;
hFig = figure('MenuBar', 'None', ...
    'Resize', 'Off', ...
    'Tag', sprintf('dontshowagaindlg_%s', this.PrefTag), ...
    'Name', this.Name, ...
    'IntegerHandle', 'Off', ...
    'HandleVisibility', 'Off', ...
    'NumberTitle', 'Off', ...
    'CloseRequestFcn', {@lclclose_cb, this}, ...
    'Position', [300 300 figw/sz.pixf minheight]*sz.pixf, ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'Visible', 'Off');

movegui(hFig, 'center');

if strcmpi(this.Icon,'warn')
    addwarnicon(this, hFig);
    textpos = [70 sz.bh+sz.uuvs*2 figw-2*sz.hfus-70 1];
else
    textpos = [sz.hfus sz.bh+sz.uuvs*2 figw-2*sz.hfus 1];
end
% Add a blank text area whos height will be determined later
h.text = uicontrol(hFig, 'Style', 'Text', ...
    'HorizontalAlignment', 'Left', ...
    'Position', textpos);

str = 'Do not show me this again';
w   = largestuiwidth({str})+sz.rbwTweak;

% Put up the don't show me again check box.
h.checkbox = uicontrol(hFig, ...
    'Style', 'Checkbox', ...
    'Position', [sz.hfus sz.vfus w sz.uh], ...
    'String', str, ...
    'Callback', {cbs.property, this, 'dontshowagain', ''}, ...
    'HorizontalAlignment', 'Left');

% Put up the close and help buttons.
buttonw   = largestuiwidth({'Close'})+4*sz.hfus;
buttonpos = [figw-buttonw-sz.hfus sz.vfus buttonw sz.bh];

if this.NoHelpButton
    closepos = buttonpos;
else
    h.help  = uicontrol(hFig, ...
        'Style', 'PushButton', ...
        'String', 'Help', ...
        'Position', buttonpos, ...
        'Callback', {cbs.method, this, @lclhelp}, ...
        'HorizontalAlignment', 'Center');
    
    closepos = buttonpos-[buttonw+sz.hfus 0 0 0];
end
h.close = uicontrol(hFig, ...
    'Style', 'PushButton', ...
    'String', 'Close', ...
    'Position', closepos, ...
    'Callback', {@lclclose_cb, this}, ...
    'HorizontalAlignment', 'Center');

l = [ ...
    handle.listener(this, this.findprop('Text'), 'PropertyPostSet', ...
    @lcltext_listener);
    handle.listener(this, this.findprop('Name'), 'PropertyPostSet', ...
    @lclname_listener);
    ];
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l, 'Handles', h, 'FigureHandle', hFig);

lcltext_listener(this);

% -------------------------------------------------------------------------
function lcltext_listener(this, eventData)

setunits(this, 'pixels');

h    = get(this, 'Handles');
sz   = gui_sizes(this);
pos  = get(h.text, 'Position');
tstr = get(this, 'Text');
newh = 0;

% We need to get the height of each element in the cell array.
temp_ui = uicontrol(this.FigureHandle, 'visible','off','style','text');
for indx = 1:length(tstr)
    
    set(temp_ui, 'String', tstr{indx});
    ext = get(temp_ui, 'Extent');
    if ext(3) > pos(3),
        newh = newh + ceil(ext(3)/pos(3))*ext(4);
    else
        newh = newh + ext(4);
    end
end

% Remove 3.5*the number of rows.  We get a lot of extra pixels from the
% extent.
newh = newh-length(tstr)*sz.pixf*3.5+sz.uh/2;
delete(temp_ui);

set(h.text, 'String', tstr);

newh = max([newh minheight*sz.pixf-sz.bh-6*sz.vfus]);
set(h.text, 'Position', [pos(1:3) newh]);

pos = get(this.FigureHandle, 'Position');
set(this.FigureHandle, 'Position', [pos(1:3) newh+sz.bh+6*sz.vfus]);

% -------------------------------------------------------------------------
function lclclose_cb(hcbo, eventStruct, this)

close(this);

% -------------------------------------------------------------------------
function lclname_listener(this, eventData)

set(this.FigureHandle, 'Name', this.Name);

% -------------------------------------------------------------------------
function lclhelp(this)

if isempty(this.HelpLocation),
    doc
else
    helpview(this.HelpLocation);
end

% -------------------------------------------------------------------------
function h = minheight

h = 130;


function addwarnicon(this, hFig)

sz  = gui_sizes(this);

% Add an axes for the icon.
h.icon = axes('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', [10*sz.pixf 70*sz.pixf 50 50]);

% Load the icons.
icons = load('dialogicons');
icons.warnIconMap(256,:)=get(hFig,'color');
h.image = image('CData',icons.warnIconData, 'Parent', h.icon);

% Set up the axes to display the icon correctly.
set(h.icon, ...
    'Box',    'off', ...
    'YDir',   'reverse', ...
    'Color',  get(hFig,'color'), ...
    'XColor',  get(hFig,'color'), ...
    'YColor',  get(hFig,'color'), ...
    'XLim',   get(h.image, 'XData')+[-0.5 0.5], ...
    'YLim',   get(h.image, 'YData')+[-0.5 0.5], ...
    'Xtick',  [], ...
    'ytick',  []);

% Set up the color map for the figure.
set(hFig, 'ColorMap', icons.warnIconMap);


% [EOF]

function thisrender(this, hFig, pos)
%THISRENDER Render the DataTypeSelector
%   THISRENDER(this, hFIG, POS) Render the data type selector to hFIG in the
%   position POS.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/12/26 22:20:57 $

sz   = gui_sizes(this);
if nargin < 3
    pos = [10 10 458 112]*sz.pixf;
    if nargin < 2
        hFig = gcf;
    end
end

hPanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'Title', 'Data type to use in export', ...
    'Visible', 'Off');

hLayout = siglayout.gridbaglayout(hPanel, ...
    'HorizontalGap', 5, ...
    'HorizontalWeights', [1 1]);

sz = gui_sizes(this);

h.selection = uicontrol(hPanel, ...
    'Callback', {@selection_cb, this}, ...
    'tag', 'suggested', ...
    'String', 'Export suggested:', ...
    'Style', 'radio');

h.selection(2) = uicontrol(hPanel, ...
    'Callback', {@selection_cb, this}, ...
    'String', 'Export as:', ...
    'tag', 'exportas', ...
    'Style', 'radio');

width = largestuiwidth(h.selection)+25*sz.pixf;

hLayout.add(h.selection(1), [1 2], 1, ...
    'TopInset', 15*sz.pixf, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', width, ...
    'Anchor', 'East');

hLayout.add(h.selection(2), [3 4], 1, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', width, ...
    'BottomInset', 5*sz.pixf, ...
    'Anchor', 'East');

h.suggested = uicontrol(hPanel,...
    'HorizontalAlignment', 'Left', ...
    'Style', 'text');

h.exportas = uicontrol(hPanel, ...
    'String', gettypes, ...
    'Style', 'popup', ...
    'tag',   'datatype_popup', ...
    'Callback', {@exportas_cb, this});

h.fractional = uicontrol(hPanel, ...
    'Style', 'text', ...
    'tag', 'datatype_fractional_length', ...
    'HorizontalAlignment', 'Left', ...
    'String', 'Fractional Length: ');

hLayout.add(h.suggested, [1 2], 2, ...
    'MinimumHeight', 2*sz.uh, ...
    'TopInset', 20*sz.pixf, ...
    'Anchor', 'west', ...
    'Fill', 'Horizontal')

hLayout.add(h.exportas, 3, 2, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', largestuiwidth(h.exportas)+40*sz.pixf, ...
    'Anchor', 'west', ...
    'TopInset', 5*sz.pixf);

hLayout.add(h.fractional, 4, 2, ...
    'Anchor', 'NorthWest', ...
    'TopInset', 2*sz.pixf, ...
    'Fill', 'Horizontal');

set(this, 'Handles', h, 'Layout', hLayout, 'Container', hPanel, 'Parent', hFig);

enable_listener(this, []);
selection_listener(this);
suggestedtype_listener(this);
exporttype_listener(this);
fractionallength_listener(this);

% Create listeners to update the HG objects
listen = [handle.listener(this, this.findprop('Selection'), ...
    'PropertyPostSet', @selection_listener); ...
    handle.listener(this, this.findprop('SuggestedType'), ...
    'PropertyPostSet', @suggestedtype_listener); ...
    handle.listener(this, this.findprop('ExportType'), ...
    'PropertyPostSet', @exporttype_listener); ...
    handle.listener(this, this.findprop('FractionalLength'), ...
    'PropertyPostSet', @fractionallength_listener); ...
    ];

% Set the callback target to itself and disable the listeners.
set(listen, 'CallbackTarget', this);

% These are when rendered listeners because they update the HG objects
set(this, 'WhenRenderedListeners', listen);

setupenablelink(this, 'Selection', 'exportas', 'exportas');

% -------------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, this)

str = popupstr(hcbo);

indx = find(strcmpi(str, gettypes));

alltypes = set(this, 'ExportType');

set(this, 'ExportType', alltypes{indx});

% -------------------------------------------------------------------------
function selection_cb(hcbo, eventStruct, this)

selection = get(hcbo, 'tag');
set(this, 'Selection', selection);

% -------------------------------------------------------------------------
function selection_listener(this, eventData)

h    = get(this, 'Handles');
hon  = findobj(h.selection, 'tag', this.Selection);
hoff = setdiff(h.selection, hon);

set(hon,  'Value', 1);
set(hoff, 'Value', 0);

% -------------------------------------------------------------------------
function suggestedtype_listener(this, eventData)

h    = get(this, 'Handles');
type = get(this, 'SuggestedType');

% Set up the default datatype string
switch type
case {'single', 'double'}
	dataTypeStr  = [type '-precision'];
    dataTypeStr(1) = upper(dataTypeStr(1));
    dataTypeStr = sprintf('%s\nfloating-point', dataTypeStr);
otherwise
    indx = strfind(type, 'int');
    bits = type(indx+3:end);
    if strcmpi(type(1), 'u')
        str = 'Unsigned';
    else
        str = 'Signed';
    end
    dataTypeStr  = sprintf('%s %s-bit integer with\n%d-bit fractional length', ...
        str, bits,this.FractionalLength);
end

% Set string in uicontrols and store information in the uicontrol user data
set(h.suggested(1), 'string', dataTypeStr);

% -------------------------------------------------------------------------
function exporttype_listener(this, eventData)

alltypes = set(this, 'ExportType');

indx = find(strcmpi(this.ExportType, alltypes));
set(this, 'ExportType', alltypes{indx});

update_fraclength(this);

% -------------------------------------------------------------------------
function fractionallength_listener(this, eventData)

update_fraclength(this);
suggestedtype_listener(this);

% -------------------------------------------------------------------------
function update_fraclength(this)

h = get(this, 'Handles');

set(h.fractional, 'String', sprintf('Fractional length: %d', this.getfraclength('pop')));

% -------------------------------------------------------------------------
function types = gettypes

types = {'Signed 32-bit integer','Signed 16-bit integer','Signed 8-bit integer', ...
    'Unsigned 32-bit integer','Unsigned 16-bit integer', 'Unsigned 8-bit integer', ...
    'Double-precision float','Single-precision float'};

% [EOF]

function thisrender(this, varargin)
%RENDER Render the magnitude specifications GUI component.
% Render the frame and uicontrols

%   Author(s): Z. Mecklai
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.8 $  $Date: 2009/03/09 19:35:34 $

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'mag'; end

hFig = get(this, 'FigureHandle');

% Call the super classes render method
super_render(this, pos);

h = get(this, 'handles');

pos = get(h.framewlabel(1), 'position');

lbl = 'Units:';

% Put up popup label
sz = gui_sizes(this);

if strncmp(get(0, 'language'), 'ja', 2)
    w = 40*sz.pixf;
else
    w = 33*sz.pixf;
end

units_lbl_pos = [pos(1)+sz.hfus pos(2)+pos(4)-sz.uh-2*sz.vfus-sz.lblTweak ...
    w sz.uh];

h.units_lbl = uicontrol(hFig,'style','text',...
    'Units','pixels',...
    'position',units_lbl_pos,...
    'visible','off',...
    'string',lbl,...
    'tag','units_lbl',...
    'HorizontalAlignment','left');

% Store the units of the object for setting up the popup
Type = get(this,'IRType');

popup_pos = [units_lbl_pos(1)+units_lbl_pos(3),...
        units_lbl_pos(2)+sz.lblTweak, ...
        sz.ebw+3*sz.uuhs sz.uh];

h.units = uicontrol(hFig,...
    'style',           'popup',...
    'BackgroundColor', 'white',...
    'Units',           'pixels',...
    'position',        popup_pos,...
    'string',          set(this, Type),...
    'tag',             'IRunits_popup',...
    'visible',         'off',...
    'Value',           find(strcmpi(set(this,Type),this.(Type))), ...
    'callback',        {@units_cb, this});

% Store the handles in the object
set(this,'handles',h);

renderlabelsnvalues(this, pos);

% Extract listener
wrl = this.WhenRenderedListeners;

% Install the listener for the units
% Install a listener for the response type
wrl = [ ...
        wrl ...
        handle.listener(this, [this.findprop('FIRUnits') this.findprop('IIRUnits')], ...
        'PropertyPostSet', @units_listener) ...
        handle.listener(this, this.findprop('IRType'), ...
        'PropertyPostSet', @irtype_listener) ...
    ];

set(wrl,'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners property of the superclass
this.WhenRenderedListeners = wrl;

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_mag_specs_frame');

% -------------------------------------------------------------------------
function units_cb(hcbo, eventData, this)
%UNITS_POPUP_CB is the callback for the Units Popupmenu

% Get value from popup
indx = get(hcbo,'value');

% Get the relevant type data
Type = get(this,'IRType');

% Set new units on the freqSpecs object
magUnitsOpts = get(hcbo,'string');

set(this,Type,magUnitsOpts{indx});

% Send event to let listeners know what property has changed.
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% -------------------------------------------------------------------------
function units_listener(this, eventData)

% Determine which impulse response type is current
Type = get(this,'IRType');

% Set the units popup to the index indicated by the current object's
% units property
set(this.Handles.units, 'value', find(strcmp(get(this, Type), set(this,Type))));

% Update the uicontrols to reflect new state
update_labels(this);

% -------------------------------------------------------------------------
function irtype_listener(this, eventData)

% Determine the new irtype
currType = get(this, 'IRType');

% set the string to the list of all valid units for this type
set(this.Handles.units, 'string', set(this, currType), ...
    'value', find(strcmpi(set(this, currType), get(this, currType))));

% Update all the uicontrols
update_labels(this);

% [EOF]

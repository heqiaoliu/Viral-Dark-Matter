function thisrender(this, varargin)
%RENDER Render the entire filter order GUI component.
% Render the frame and uicontrols

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/01/20 15:36:02 $

frpos = parserenderinputs(this, varargin{:});
bgc   = get(0,'defaultuicontrolbackgroundcolor');
hFig  = get(this,'figureHandle');
sz    = gui_sizes(this);

% Calculate this frame's position and then render the frame.
if isempty(frpos),
    frpos = sz.pixf.*[217 186 178 74];
end

h.framewlabel = framewlabel(hFig,frpos,'Filter Order','filterOrderFrame',bgc,'off');

%
% Render the radio buttons and popup.
%

% Define the strings
orderStrs = {'Specify order:','Minimum order'};
tags = set(this,'mode');%{'specify','minimum'}

% Get structure of callback handles
cbs = {{@specifyOrder_cb,this},{@minimumOrder_cb,this}};

h.rbs = [-1 -1]; % Preallocate for speed.

pos = [frpos(1)+sz.hfus, frpos(2)+frpos(4),...
    largestuiwidth(orderStrs,'radiobutton') sz.uh];

% Put up the radio buttons
for n=1:length(orderStrs),
    
    pos(2) = pos(2)-(sz.uh+2*sz.vfus+sz.lblTweak);
    h.rbs(n)=uicontrol(hFig,'style','radiobutton',...
        'BackgroundColor',bgc,...
        'position',pos,...
        'visible','off',...
        'string',orderStrs{n},...
        'Tag',tags{n},...
        'callback',cbs{n});
end

if length(tags) > 2,
    set(h.rbs(2), 'String', '');
    pos(1) = pos(1) + 20*sz.pixf;
    
    for indx = 1:length(tags)-1,
        lbls{indx} = [upper(tags{indx+1}(1)) tags{indx+1}(2:end)];
        sndx = strfind(lbls{indx}, ' ');
        if isempty(sndx),
            lbls{indx} = [lbls{indx} ' order'];
        else
            lbls{indx} = [lbls{indx}(1:sndx) 'order (' lbls{indx}(sndx+1:end) ')'];
        end
    end
    pos(3) = largestuiwidth(lbls)+sz.rbwTweak;
    
    if pos(3)+pos(1) > frpos(1)+frpos(3)+sz.hfus
        pos(3) = frpos(1)+frpos(3)-pos(1)-sz.hfus;
    end
    
    pos(2) = pos(2) + sz.lblTweak;
    
    h.pop = uicontrol(hFig, 'Style', 'Popup', ...
        'BackgroundCOlor', 'w', ...
        'Position', pos, ...
        'Visible', 'off', ...
        'Tag', 'minimum', ...
        'String', lbls, ...
        'Callback', cbs{2}, ...
        'HorizontalAlignment', 'Left', ...
        'UserData', tags(2:end));
else
    h.pop = [];
end

%
% Render the edit box
%

% Find the position of specify order
specorder_pos = get(h.rbs(1),'position');

h.eb = uicontrol(hFig,'style','edit',...
    'BackgroundColor','white',...
    'position',[specorder_pos(1)+specorder_pos(3) specorder_pos(2) 40*sz.pixf sz.uh],...
    'visible','off',...
    'HorizontalAlignment','left',...
    'Tag','order_eb',...
    'callback',{@order_eb_cb,this},...
    'String',get(this, 'order'));

% Store handles in object
set(this,'handles',h);

% Install listener for the mode
% Install a listener for the isMinOrd property
% Install a listener for the order property
listeners = [ ...
    handle.listener(this, this.findprop('mode'),'PropertyPostSet', @mode_listener); ...
    handle.listener(this, this.findprop('isMinOrd'), 'PropertyPostSet', @is_minord_listener); ...
    handle.listener(this, this.findprop('order'), 'PropertyPostSet', @order_listener); ...
    ];

set(listeners,...
    'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners
this.WhenRenderedListeners = listeners;

mode_listener(this);
is_minord_listener(this);

cshelpcontextmenu(this, 'fdatool_filter_order_specs_frame');

%-----------------------------------------------------------------
function minimumOrder_cb(h_source, eventdata, this, varargin)
%MINIMUMORDER_CB Callback for the minimum order radio button.

% Because HG deselects radio-buttons when they are clicked on and
% already selected, we need to ensure that it stays selected.

if strcmpi(get(h_source, 'style'), 'popupmenu'),
    indx = get(h_source, 'Value') + 1;
else
    indx = 2;
end

lcl_setmode(h_source,this,indx);

%-----------------------------------------------------------------
function order_eb_cb(h_source, eventdata, this, varargin)
%ORDER_EB_CB Callback for the specify order edit box.

% Get value in edit box
val = fixup_uiedit(h_source);

% Set the mode to specify
set(this,'order',val{1});
% Notify any listeners that this event occurred
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

%------------------------------------------------------------------
function specifyOrder_cb(h_source, eventdata, this, varargin)
%SPECIFYORDER_CB Callback for the specify order radio button.

lcl_setmode(h_source,this,1);

%------------------------------------------------------------------
function lcl_setmode(h_source,this,indx)
% Because HG deselects radio-buttons when they are clicked on and
% already selected, we need to ensure that it stays selected.

modeOpts = set(this,'mode'); %{'specify','minimum'} <- from the subclass
if strcmpi(get(this,'mode'),modeOpts{indx}),
    if ~strcmpi(get(h_source, 'style'), 'popupmenu'),
        set(h_source,'value',1);
    end
else
    % Set the mode to the specified value
    set(this,'mode',modeOpts{indx});
    
    % Notify any listeners that this event occurred
    send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));
end

% [EOF]

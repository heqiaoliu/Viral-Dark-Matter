function rendercontrols(this, pos, varargin)
%RENDERCONTROLS   Render the properties.
%   RENDERCONTROLS(THIS, POS) Render all the public set and get properties,
%   using the 'Description' from the label and determining the UIControl
%   style from the datatype of the property.  A listener will be created on
%   all the properties' 'PropertyPostSet' event and will call the
%   PROP_LISTENER method.  This listener will be saved in the
%   WhenRenderedListeners property.  The handle to each of the UIControl's
%   will be stored in the Handles property in a field of the same name as
%   the property, but in all lower case.  If a label is needed it will be
%   stored in '([propname '_lbl'])' and its string will be set to the
%   Description.
%
%   RENDERCONTROLS(THIS, POS, PROPS) Render only the properties passed in
%   the cell of strings PROPS.
%
%   RENDERCONTROLS(THIS, POS, PROPS, DESCS) Use the cell of strings DESCS to
%   label the controls instead of their descriptions.
%
%   RENDERCONTROLS(THIS, POS, PROPS, DESCS, STYLES) Use the cell of strings
%   STYLES instead of mapping the properties' DataTypes to UIControl
%   styles.
%
%   DataType to UIControl Map
%   On/Off          checkbox
%   bool
%   string          editbox
%   all others      popup

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2010/05/20 03:10:40 $

error(nargchk(2,5,nargin,'struct'));

hp = [];
visState = 'Off';
if length(pos) == 1 && ishghandle(pos)
    if ishghandle(pos, 'uipanel') || ishghandle(pos, 'uicontainer')
        ispanel = true;
        visState = 'On';
    end
    if ishghandle(pos, 'figure') || ispanel
        hp = pos;
        pos = [];
        if ~isempty(varargin)
            if length(varargin{1}) == 4 && isnumeric(varargin{1})
                pos = varargin{1};
                varargin(1) = [];
            end
        end
        if isempty(pos)
            pos = getpixelposition(hp);
            pos(1:2) = 0;
        end
    end
end

[props, tags, strs, styles] = parseinputs(this, varargin{:});

cbs  = siggui_cbs(this);

if isempty(hp)
    hp   = get(this, 'Container');
    if isempty(hp)
        hp = get(this, 'Parent');
    end
end
sz   = gui_sizes(this);
h    = get(this, 'Handles');

skip  = (pos(4)-length(tags)*sz.uh)/(length(tags)+1)+sz.uh;

lblwidth = zeros(1, numel(strs));
for indx = 1:numel(strs)
    if ~strcmpi(styles{indx}, 'checkbox') && ~isempty(strs{indx}),
        strs{indx} = sprintf('%s: ', xlate(strs{indx}));
        lblwidth(indx) = largestuiwidth(strs(indx));
    end
end
lblwidth = max(lblwidth);

% Get total position.
pos = [pos(1)+sz.hfus pos(2)-sz.uh pos(3)-sz.hfus*2 sz.uh];

% Get the label position
lblpos = pos;
lblpos(3) = lblwidth;
lblpos(2) = lblpos(2)-sz.lblTweak;

% Get the edit/popup position
editpos = pos;
editpos(1) = editpos(1) + lblwidth + sz.uuhs/2;
editpos(3) = pos(3) - lblwidth - sz.uuhs/2;

minwidth = 20*sz.pixf;
if editpos(3) < minwidth
    lblpos(3)  = lblpos(3)-minwidth+editpos(3);
    editpos(1) = editpos(1)-minwidth+editpos(3);
    editpos(3) = minwidth;
end

tooltips = gettooltips(this);
[cshtags, cshtool] = getcshtags(this);

% Render the controls
for indx = length(tags):-1:1
    pos(2)     = pos(2) + skip;
    editpos(2) = editpos(2) + skip;
    lblpos(2)  = lblpos(2) + skip;
    ispop = false;
    switch styles{indx}
        case 'checkbox'
            cpos = pos;
            cpos(3) = largestuiwidth(strs(indx))+sz.rbwTweak;
            inputs = {'Position', cpos, 'String', strs{indx}};
        case {'edit', 'popup'}
            inputs = {'Position', editpos};
            if strcmpi(get(props(indx), 'DataType'), 'string vector'),
                inputs = [inputs, {'Max', 2}]; %#ok<AGROW>
            end
            if strcmpi(styles{indx}, 'popup')
                ispop = true;
                validStrings = set(this, tags{indx});
                inputs = [inputs, {'String', validStrings}]; %#ok<AGROW>
            end
            if ~isempty(strs{indx}),
                tag = [tags{indx} '_lbl'];
                if isfield(tooltips, tag),
                    lblinputs = {'Tooltip', tooltips.(tag)};
                else
                    lblinputs = {};
                end
                
                h.(tag) = uicontrol(hp, ...
                    'Style', 'Text', ...
                    'Visible', visState, ...
                    'HorizontalAlignment', 'Left', ...
                    'Tag', tag, ...
                    'String', xlate(strs{indx}), ...
                    lblinputs{:}, ...
                    'Position', lblpos);
                if isfield(cshtags, tags{indx}),
                    cshelpcontextmenu(h.(tag), cshtags.(tags{indx}), cshtool);
                end
            end
    end
    if isfield(tooltips, tags{indx}),
        inputs = [inputs {'Tooltip', tooltips.(tags{indx})}]; %#ok<AGROW>
    end
    h.(tags{indx}) = uicontrol(hp, ...
        'Style', styles{indx}, ...
        'Visible', visState, ...
        'HorizontalAlignment', 'Left', ...
        'Tag', tags{indx}, ...
        inputs{:}, ...
        'Callback', {cbs.property, this, tags{indx}, sprintf('Change %s', strs{indx})});
    if ispop
        setappdata(h.(tags{indx}), 'PopupStrings', validStrings);
    end
    if isfield(cshtags, tags{indx}),
        cshelpcontextmenu(h.(tags{indx}), cshtags.(tags{indx}), cshtool);
    end
end

set(this, 'Handles', h);

% Make sure everything is enabled properly.
h = handles2vector(this);
h(~isprop(h, 'enable')) = [];
setenableprop(h, this.Enable);

% Add the listener to capture the property changes.
l = handle.listener(this, props, 'PropertyPostSet', @prop_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));

for indx = 1:length(tags),
    try
        prop_listener(this, tags{indx});
    catch ME %#ok<NASGU>
        % NO OP
    end
end

% --------------------------------------------------------
function [props, tags, strs, styles] = parseinputs(this, tags, strs, styles)

% Get the tags (properties)
if nargin < 2,
    props = find(this.classhandle.Properties, ...
        'AccessFlags.PublicSet', 'On', 'AccessFlags.PublicGet', 'On', ...
        '-not', 'Name', 'Tag'); %#ok<GTARG>
    tags  = get(props, 'Name');
    
else
    tags = cellstr(tags);
    for indx = 1:length(tags)
        props(indx) = findprop(this, tags{indx}); %#ok<AGROW>
    end
end
tags = lower(tags);

% Get the descriptions
if nargin < 3,
    for indx = 1:length(props),
        strs{indx} = get(props(indx), 'Description');
        
        % If the description is empty, get the string from the name.  Don't
        % get it from "tags" as this is lower cased.
        if isempty(strs{indx}),
            strs{indx} = interspace(get(props(indx), 'Name'));
        end
    end
else
    strs = cellstr(strs);
end

% Get the uicontrol styles
if nargin < 4,
    for indx = 1:length(tags)
        switch lower(get(props(indx), 'DataType'))
            case {'on/off', 'bool', 'strictbool', 'yes/no'}
                styles{indx} = 'checkbox';
            case {'string', 'string vector'}
                styles{indx} = 'edit';
            otherwise
                styles{indx} = 'popup';
        end
    end
else
    styles = cellstr(styles);
end

% [EOF]

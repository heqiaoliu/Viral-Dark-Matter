function rendercontrols(this, row, col, varargin)
%RENDERCONTROLS   Render the properties.
%   RENDERCONTROLS(THIS) Render all the public set and get properties,
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
%   RENDERCONTROLS(THIS, PROPS) Render only the properties passed in
%   the cell of strings PROPS.
%
%   RENDERCONTROLS(THIS, PROPS, DESCS) Use the cell of strings DESCS to
%   label the controls instead of their descriptions.
%
%   RENDERCONTROLS(THIS, PROPS, DESCS, STYLES) Use the cell of strings
%   STYLES instead of mapping the properties' DataTypes to UIControl
%   styles.
%
%   DataType to UIControl Map
%   On/Off          checkbox
%   bool
%   string          editbox
%   all others      popup

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:19:44 $

error(nargchk(2,5,nargin,'struct'));

[props, tags, strs, styles] = parseinputs(this, varargin{:});

sz     = gui_sizes(this);
cbs    = siggui_cbs(this);
hPanel = get(this, 'Container');
h      = get(this, 'Handles');

hLayout = get(this, 'Layout');
if isempty(hLayout)
    hLayout = siglayout.gridbaglayout(this.Container);
    set(this, 'Layout', hLayout);
end

tooltips = gettooltips(this);
[cshtags, cshtool] = getcshtags(this);

% Render the controls
for indx = 1:length(tags)
    
    switch styles{indx}
        case 'checkbox'
            width = 2;
            inputs = {'String', strs{indx}};
        case {'edit', 'popup'}
            width = 1;
            inputs = {};
            if strcmpi(get(props(indx), 'DataType'), 'string vector'),
                inputs = [inputs, {'Max', 2}];
            end
            if strcmpi(styles{indx}, 'popup')
                inputs = {inputs{:}, 'String', set(this, tags{indx})};
            end
            if ~isempty(strs{indx}),
                tag = [tags{indx} '_lbl'];
                if isfield(tooltips, tag),
                    lblinputs = {'Tooltip', tooltips.(tag)};
                else
                    lblinputs = {};
                end
                
                h.(tag) = uicontrol(hPanel, ...
                    'Style', 'Text', ...
                    'HorizontalAlignment', 'Left', ...
                    'Tag', tag, ...
                    'String', strs{indx}, ...
                    lblinputs{:});
                if isfield(cshtags, tags{indx}),
                    cshelpcontextmenu(h.(tag), cshtags.(tags{indx}), cshtool);
                end
                
                hLayout.add(h.(tag), row+indx-1, col, ...
                    'Fill', 'Horizontal', ...
                    'Anchor', 'SouthWest', ...
                    'MinimumHeight', sz.uh-sz.lblTweak);
                
            end
    end
    if isfield(tooltips, tags{indx}),
        inputs = {inputs{:}, 'Tooltip', tooltips.(tags{indx})};
    end
    h.(tags{indx}) = uicontrol(hPanel, ...
        'Style', styles{indx}, ...
        'HorizontalAlignment', 'Left', ...
        'Tag', tags{indx}, ...
        inputs{:}, ...
        'Callback', {cbs.property, this, tags{indx}, sprintf('Change %s', strs{indx})});
    if isfield(cshtags, tags{indx}),
        cshelpcontextmenu(h.(tags{indx}), cshtags.(tags{indx}), cshtool);
    end
    
    if width == 2
        colindx = [col:col+1];
    else
        colindx = col+1;
    end
    
    hLayout.add(h.(tags{indx}), row+indx-1, colindx, ...
        'Fill', 'Horizontal', ...
        'MinimumHeight', sz.uh);
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
    catch
        % NO OP
    end
end

% --------------------------------------------------------
function [props, tags, strs, styles] = parseinputs(this, tags, strs, styles)

% Get the tags (properties)
if nargin < 2,
    props = find(this.classhandle.Properties, ...
        'AccessFlags.PublicSet', 'On', 'AccessFlags.PublicGet', 'On', ...
        '-not', 'Name', 'Tag');
    tags  = get(props, 'Name');
    
else
    tags = cellstr(tags);
    for indx = 1:length(tags)
        props(indx) = findprop(this, tags{indx});
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

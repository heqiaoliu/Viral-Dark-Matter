function thisrender(this, varargin)
%THISRENDER Render the Current Filter Information Frame

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.22.4.15 $  $Date: 2009/07/14 04:03:33 $

pos = parserenderinputs(this, varargin{:});
sz  = gui_sizes(this);
if isempty(pos),
    pos = [10 10 178 176]*sz.pixf;
end

% Render everything evenly spaced
hFig = get(this, 'Parent');

hPanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'Visible', 'Off', ...
    'Title', 'Current Filter Information');

lbls = {'Structure:', 'Order:', 'Stable:', 'Source:'};
tags = {'structure',  'order',  'stable',  'source'};
h    = get(this, 'Handles');

spacing = (pos(4) - length(lbls)*sz.uh)/2;

if strncmp(get(0, 'language'), 'ja', 2)
    buffer = 2*sz.pixf;
else
    buffer = 0;
end

x = sz.hfus-3*sz.pixf;
y = pos(4) - spacing;
w = largestuiwidth(lbls);
ht = sz.uh;

for indx = 1:length(lbls),
    y = y - sz.uh;
    h.([tags{indx} '_lbl']) = uicontrol(hPanel, ...
        'Style', 'Text', ...
        'Tag', tags{indx}, ...
        'HorizontalAlignment', 'Left', ...
        'ForegroundColor', [0 0 1], ...
        'Position', [x y w+buffer ht], ...
        'String', lbls{indx});
    h.(tags{indx}) = uicontrol(hPanel, ...
        'Style', 'Text', ...
        'Tag', tags{indx}, ...
        'HorizontalAlignment', 'Left', ...
        'Position', [x+w+sz.uuhs-4*sz.pixf y pos(3)-w-sz.uuhs-2*sz.hfus+8*sz.pixf ht]);
end

set(convert2vector(h), 'Units', 'Pixels');

set(this, 'Handles', h, 'Container', hPanel);

cshelpcontextmenu(this, 'fdatool_currentfilterinfo_frame');

% Install Listeners
% Create the listeners
listener = [ ...
    handle.listener(this, this.findprop('Filter'), ...
    'PropertyPostSet', @update); ...
    handle.listener(this, this.findprop('Source'), ...
    'PropertyPostSet', @source_listener); ...
    ];

% Set this to be the input argument to these listeners
set(listener,'CallbackTarget',this);

% Save the listeners
set(this,'WhenRenderedListeners',listener);

update(this);
source_listener(this);

structurePos = get(h.structure, 'Position');
structureExt = get(h.structure, 'Extent');

% If the extent exceeds the actual width, we need to increase the height of
% the structure widgets so that all the text is displayed properly.
if structureExt(3) > structurePos(3)
    structurePos(4) = structurePos(4)+sz.uh;
    set(h.structure, 'Position', structurePos);
    
    labelPos = get(h.structure_lbl, 'Position');
    labelPos(4) = labelPos(4)+sz.uh;
    set(h.structure_lbl, 'Position', labelPos);
    
end


% ----------------------------------------------------------------------
function update(this, eventData)
%UPDATE Update the CFI object

h  = get(this,'Handles');
Hd = get(this, 'Filter');

if isempty(Hd)
    stable = xlate('Yes');
    color  = [0 0 0];
    set(h.order,     'String', '50');
    set(h.structure, 'String', 'Direct-Form FIR');
else

    if strcmpi(this.FastUpdate, 'off')
        setuplayout(this);
    end

    if isstable(Hd)
        stable = xlate('Yes');
        color  = [0 0 0];
    else
        stable = xlate('No');
        color  = [1 0 0];
    end
end

set(h.stable, 'Foregroundcolor', color, 'String', stable);

% ----------------------------------------------------------------------
function setuplayout(this)

sz = gui_sizes(this);
hp = get(this, 'Container');
h  = get(this, 'Handles');
Hd = get(this, 'Filter');

ht = sz.uh-2*sz.pixf;

hLayout = get(this, 'Layout');
if isempty(hLayout)
    hLayout = siglayout.gridbaglayout(hp, ...
        'VerticalWeights',   [2 0 0 0 0 0 0 0 3], ...
        'HorizontalWeights', [0 1], ...
        'HorizontalGap',     5*sz.pixf);

    hLayout.add(h.source_lbl, 9, 1, ...
        'MinimumWidth', largestuiwidth(h.source_lbl), ...
        'Anchor',       'North', ...
        'BottomInset',  10*sz.pixf, ...
        'Fill',         'Both');

    hLayout.add(h.source, 9, 2, ...
        'Anchor',      'North', ...
        'BottomInset', 10*sz.pixf, ...
        'Fill',        'Both');

    hLayout.add(h.stable_lbl, 8, 1, ...
        'MinimumWidth',  largestuiwidth(h.stable_lbl), ...
        'MinimumHeight', ht, ...
        'Fill',          'Horizontal');

    hLayout.add(h.stable, 8, 2, ...
        'MinimumHeight', ht, ...
        'Fill',          'Horizontal');

    set(this, 'Layout', hLayout);
end

fi = cfi(Hd);

labels = fieldnames(fi);

oldgrid = get(hLayout, 'Grid');

oldgrid([8 9], :) = [];
oldgrid(:,1)      = [];

oldfields = get(oldgrid(~isnan(oldgrid)), 'tag');

issamestructure = isequal(oldfields, lower(labels));

if ~issamestructure
    % The first field is special and gets extra room on the top.
    remove(hLayout, 1, 1);
    remove(hLayout, 1, 2);

    if strncmp(get(0, 'language'), 'ja', 2)
        buffer = 2*sz.pixf;
    else
        buffer = 0;
    end
    
    tag = lower(labels{1});
    hLayout.add(h.([tag '_lbl']), 1, 1, ...
        'TopInset',     15*sz.pixf, ...
        'Fill',         'Horizontal', ...
        'MinimumWidth', largestuiwidth(h.([tag '_lbl']))+buffer, ...
        'Anchor',       'South');
    hLayout.add(h.(tag), 1, 2, ...
        'TopInset', 15*sz.pixf, ...
        'Anchor',   'South', ...
        'Fill',     'Horizontal');

    set(h.(lower(labels{1})), 'String', fi.(labels{1}));
    set([h.([tag '_lbl']) h.(tag)], 'Visible', 'On');

    nlabels = length(labels);
    for indx = 2:nlabels
        tag = lower(labels{indx});

        % Create any controls that aren't there yet.
        if ~isfield(h, tag)
            h.([tag '_lbl']) = uicontrol(hp, ...
                'Style',               'Text', ...
                'HorizontalAlignment', 'Left', ...
                'tag',                 tag, ...
                'Visible',             'Off', ...
                'ForegroundColor',     [0 0 1], ...
                'String',              sprintf('%s:', interspace(labels{indx})));
            h.(tag) = uicontrol(hp, ...
                'Style', 'Text', ...
                'HorizontalAlignment', 'Left', ...
                'Tag', tag, ...
                'Visible', 'Off');
        end

        % Remove the old labels
        hLayout.remove(indx, 1);
        hLayout.remove(indx, 2);

        % Add the labels specified by the CFI method.
        hLayout.add(h.([tag '_lbl']), indx, 1, ...
            'Fill', 'Horizontal', ...
            'MinimumHeight', ht, ...
            'MinimumWidth', largestuiwidth(h.([tag '_lbl']))+buffer);

        hLayout.add(h.(tag), indx, 2, ...
            'MinimumHeight', ht, ...
            'Fill', 'Horizontal');

        set([h.(tag) h.([tag '_lbl'])], 'Visible', 'On');

        % Set the label to match what the cfi method tells us.
        set(h.(tag), 'String', fi.(labels{indx}));
    end

    % Remove anything that is left over from the last cfi.
    for indx = nlabels+1:7
        remove(hLayout, indx, 1);
        remove(hLayout, indx, 2);
    end
else
    for indx = 1:length(labels)
        tag = lower(labels{indx});
        set(h.(tag), 'String', fi.(labels{indx}));
    end
end

% Make sure everything outside of the layout is invisible.
hOld = setdiff(convert2vector(h), hLayout.Grid(ishghandle(hLayout.Grid)));
set(hOld, 'Visible','Off');

set(this, 'Handles', h);
ht = max(ht, getbestsize(h.(lower(labels{1})), 'height'));

hLayout.setconstraints(1, 1, 'MinimumHeight', ht);
hLayout.setconstraints(1, 2, 'MinimumHeight', ht);

% -------------------------------------------------------------------------
function source_listener(this, eventData)

set(this.Handles.source, 'String', get(this, 'Source'));

% [EOF]

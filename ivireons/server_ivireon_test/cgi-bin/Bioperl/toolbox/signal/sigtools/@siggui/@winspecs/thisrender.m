function thisrender(this, hFig, pos)
%THISRENDER Render the window specifications component.

%   Author(s): V.Pellissier
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.7 $  $Date: 2009/10/16 06:42:50 $ 

sz = gui_sizes(this);
if nargin < 3
    pos  = [10 10 232 212]*sz.pixf;
    if nargin < 2
        hFig = gcf;
    end
end

hPanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'Visible', 'Off', ...
    'Title', xlate('Current Window Information'));

lbls = {'Name:', ...
    'Type:', ...
    'MATLAB code:', ...
    'Length:', ...
    'Parameter:', ...
    'Parameter2:', ...
    'Sampling:'};

style = {'', ...
    'popupmenu', ...
    'edit', ...
    'edit', ...
    'edit', ...
    'edit', ...
    'popupmenu'};

tags = {'winname', ...
    'type', ...
    'matlabexpression', ...
    'length', ...
    'parameter', ...
    'parameter2', ...
    'samplingflag'};

[winclassnames, winnames] = findallwinclasses;

% Remove the functiondefined class
index = strcmpi('functiondefined', winclassnames);
winnames(index) = [];

param = getparameter(this);
if isempty(param)
    strs = {{this.Name}, ...
        winnames, ...
        this.MATLABExpression, ...
        this.Length, ...
        param, ...
        param, ...
        {'Symmetric','Periodic'}};
else
    strs = {{this.Name}, ...
        winnames, ...
        this.MATLABExpression, ...
        this.Length, ...
        param{1}, ...
        param{2}, ...
        {'Symmetric','Periodic'}};
end

cb = siggui_cbs(this);
cbs = {{cb.method, this, @select_cb}, ...
    {cb.method, this, @type_cb}, ...
    {cb.method, this, @userdef_cb}, ...
    {cb.property, this, 'length', ''}, ...
    {cb.method, this, @parameter_cb}, ...
    {cb.method, this, @parameter_cb}, ...
    {cb.property, this, 'samplingflag', ''}};

% Position relative to the UIPanel, not the figure.
lblpos = [sz.hfus pos(4)-40*sz.pixf 90*sz.pixf sz.uh-sz.lblTweak];
x      = lblpos(1)+lblpos(3)+sz.uuhs;
ctlpos = [x lblpos(2) pos(3)-x-sz.uuhs sz.uh];

% Render the combo box
h.winname = sigcombobox(hPanel, ...
    'Callback', cbs{1}, ...
    'String', strs{1}, ...
    'Position', ctlpos, ...
    'tag', 'combopop');

% hLayout = siglayout.gridbaglayout(hPanel);
% 
% set(hLayout, ...
%     'VerticalGap', 5, ...
%     'HorizontalGap', 5, ...
%     'HorizontalWeights', [0 1]);
% 
% hLayout.add(h.winname, 1, 2, ...
%     'Fill', 'Horizontal', ...
%     'TopInset', 10*sz.pixf, ...
%     'MinimumHeight', sz.uh);

nlbls = length(lbls);

skip = (lblpos(2)-40*sz.pixf-(nlbls-1)*sz.uh)/(nlbls-1);

% Render labels from top to bottom
for n=1:nlbls
    
    h.([tags{n} '_lbl']) = uicontrol(hPanel, ...
        'style', 'text',...
        'HorizontalAlignment', 'left', ...
        'string', lbls{n},...
        'Position', lblpos, ...
        'Tag', [tags{n} '_lbl']);
    
%     hLayout.add(h.([tags{n} '_lbl']), n, 1, ...
%         'MinimumHeight', sz.uh-sz.lblTweak, ...
%         'MinimumWidth',  90*sz.pixf, ...
%         'Anchor', 'Southwest', ...
%         'Fill', 'Horizontal');

    if n > 1
        % Create the uicontrol
        h.(tags{n}) = uicontrol(hPanel, ...
            'style', style{n}, ...
            'callback', cbs{n}, ...
            'horizontalAlignment', 'left', ...
            'string', strs{n}, ...
            'Position', ctlpos, ...
            'Tag', tags{n});

%         hLayout.add(h.(tags{n}), n, 2, ...
%             'MinimumHeight', sz.uh, ...
%             'Fill', 'Horizontal');
    end
    
    ctlpos(2) = ctlpos(2)-sz.uh-skip;
    lblpos(2) = ctlpos(2);
end

set(h.type, 'BackgroundColor', 'w');

ctlpos = get(h.length, 'Position');
ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
set(h.length, 'Position', ctlpos);

ctlpos = get(h.parameter, 'Position');
ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
set(h.parameter, 'Position', ctlpos);

ctlpos = get(h.parameter2, 'Position');
ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
set(h.parameter2, 'Position', ctlpos);

% hLayout.setconstraints(4, 2, 'LeftInset', 60*sz.pixf);
% hLayout.setconstraints(5, 2, 'LeftInset', 60*sz.pixf);

w = 70*sz.pixf;

h.pb = uicontrol(hPanel, ...
    'style', 'pushbutton', ...
    'callback', {cb.method, this, 'apply'}, ...
    'string', 'Apply', ...
    'Position', [(pos(3)-w)/2 10*sz.pixf w sz.bh], ...
    'Tag', 'apply');

% hLayout.add(h.pb, 7, 1:2, ...
%     'MinimumWidth', largestuiwidth(h.pb)+20*sz.pixf, ...
%     'MinimumHeight', sz.bh);

% Store handles in object
set(this,'Handles', h, ...
    'FigureHandle', hFig, ...
    'Container', hPanel); %, ...
%     'Layout', hLayout);

% Create the listeners
listener = [ ...
    handle.listener(this, this.findprop('Name'), ...
    'PropertyPostSet', @name_listener); ...
    handle.listener(this, this.findprop('Window'), ...
    'PropertyPostSet', @window_listener); ...
    handle.listener(this, [this.findprop('MATLABExpression'), ...
        this.findprop('length') this.findprop('samplingFlag')], ...
    'PropertyPostSet', @lclprop_listener); ...
    handle.listener(this, this.findprop('isModified'), ...
    'PropertyPostSet', @lclismodified_listener)];

addlistener(h.winname, 'String', 'PostSet', @(hSrc,ev) lclname_listener(this, ev, h.winname));

% Set this to be the input argument to these listeners
set(listener, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', listener);

% Add context-sensitive help
cshelpcontextmenu(this, 'wintool_winspecs_frame', 'WinTool');

window_listener(this);

%-------------------------------------------------------------------------
%         CALLBACKS
%-------------------------------------------------------------------------
function select_cb(this)
%SELECT_CB Callback of the popup of the combobox

val = get(this.Handles.winname, 'Value');
select_currentwin(this, val);

%-------------------------------------------------------------------------
function type_cb(this)
%TYPE_CB Callback of the Type popup 

% Find the function handle of the window in the database
[winclassnames, winnames] = findallwinclasses;
% Remove the functiondefined class
index = strcmpi('functiondefined', winclassnames);
winclassnames(index) = [];

ind = get(this.Handles.type, 'Value');

% Instantiate a new window object
newwin = feval(str2func(['sigwin.',winclassnames{ind}]));

% Set the Window property
set(this, 'Window', newwin);

%-------------------------------------------------------------------------
function userdef_cb(this)
%USERDEF_CB Callback of the User Defined editbox

str = get(this.Handles.matlabexpression, 'String');
set(this, 'MATLABExpression', str);


%-------------------------------------------------------------------------
function parameter_cb(this)
%PARAMETER_CB Callback of the parameter editbox 

strs{1} = get(this.Handles.parameter, 'String');
strs{2} = get(this.Handles.parameter2, 'String');
paramstruct = get(this, 'Parameters');
param=getparameter(this);

paramstruct.(param{1}) = strs{1};
if ~isempty(param{2})
    paramstruct.(param{2}) = strs{2};
end

set(this, 'Parameters', paramstruct);

%-------------------------------------------------------------------------
%         LISTENERS
%-------------------------------------------------------------------------
function lclismodified_listener(this, ~)

if this.isModified
    enab = this.Enable;
else
    enab = 'Off';
end

set(this.Handles.pb, 'Enable', enab);

%-------------------------------------------------------------------------
function lclprop_listener(this, eventData)

prop_listener(this, eventData);

%-------------------------------------------------------------------------
function window_listener(this, ~)

enable_listener(this);

%-------------------------------------------------------------------------
function name_listener(this, ~)

newname = get(this, 'Name');

% Update the editbox of the combobox
h   = get(this,'Handles');
val = get(h.winname, 'Value');
str = cellstr(get(h.winname, 'String'));
if ~isempty(str),
    str{val} = newname;
end

% Update the backgroundcolor 
setenableprop(h.winname, this.Enable);

%-------------------------------------------------------------------------
function lclname_listener(this, ~, hcbo)
%NAME_CBS Callback of the editbox of the combobox

allstr = get(hcbo, 'String');
if length(allstr) == 1 && isempty(allstr{1}), return; end

name = popupstr(hcbo);
if isvarname(name) && ~isreserved(name, 'm'),
    set(this, 'Name', name);
else
    senderror(this, ['''' name ''' is not a valid name.']);
    set(hcbo, 'String', get(this, 'Name'));
end


% [EOF]


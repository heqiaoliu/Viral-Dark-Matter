function selector_render(this, varargin)
%SELECTOR_RENDER Render the Selector
%   SELECTOR_RENDER(H, hFig, POS) Render the Selector to the figure hFig
%   with the position POS.
%
%   SELECTOR_RENDER(H, hFig, POS, CTRLPOS) Render the Selector.  CTRLPOS
%   will be used to determine the position of the radiobuttons and popups,
%   instead of POS, which will be used to render the frame and label.  If
%   CTRLPOS is not used POS will determine the position of the controls.
%
%   SELECTOR_RENDER(H, POS) Render the selector to the position POS.  When
%   hFig is not specified, the value stored in the object is used.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/01/05 18:01:00 $

[framePos, controlPos, msg] = parse_inputs(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Render the frame and controls
hFig  = get(this, 'FigureHandle');
frLbl = get(this, 'Name');

if isempty(framePos),
    h.frame = [];
else
    h.frame = framewlabel(hFig, framePos, frLbl, 'selectorframe', ...
        get(0,'defaultuicontrolbackgroundcolor'), this.Visible);
end

cbs     = callbacks(this);
strings = get(this, 'Strings');
tags    = get(this, 'Identifiers');
sz      = gui_sizes(this);
skip    = (controlPos(4) - length(tags)*sz.uh)/(length(tags)+1);
y       = controlPos(2)+controlPos(4);

% Set up the spacing for the radios and popups
erbtweak = gettweak(this);
popwidth = getpopupwidth(strings);

% Find the width of all the UIcontrols on the frame
% The Space, the radiobutton, the radiobutton label and the popupmenu
twidth = sz.hfus+erbtweak+sz.rbwTweak+popwidth;

% Make sure that the popup does not go outside the frame
if twidth > controlPos(3)-sz.hfus,
    popwidth = popwidth - twidth+controlPos(3)-sz.hfus;
end

radwidth = controlPos(3)-2*sz.hfus;
twidth = sz.hfus+radwidth;

if twidth > controlPos(3)-sz.hfus,
    radwidth = radwidth - twidth+controlPos(3)-sz.hfus;
end

% Set up the controlPositions of the radios and popups
radPos = [controlPos(1)+sz.hfus y radwidth sz.uh];
popPos = [controlPos(1)+sz.hfus+erbtweak+sz.rbwTweak y popwidth sz.uh];

enabState = get(this, 'Enable');
visState = get(this, 'Visible');

for i = 1:length(tags)
    y = y-skip-sz.uh;
    radPos(2) = y;
    popPos(2) = y;
    
    % Render the radio button
    h.radio(i) = uicontrol(hFig, ...
        'style', 'radio', ...
        'Enable', enabState, ...
        'Visible', visState, ...
        'Callback', {cbs.radio, this}, ...
        'Interruptible', 'off', ...
        'position', radPos);
    
    % If the index into the tags is a cell, render a popup
    if iscell(tags{i}),
        tag = tags{i}{1};
        
        % If the tags and strings are the same length, the popup has a label
        if ~difference(this, i),
            str = strings{i}{1};
            strs = {strings{i}{2:end}};
        else
            str = '';
            strs = strings{i};
        end
        ptags = {tags{i}{2:end}};
    else
        tag = tags{i};
        str = strings{i};
        strs = {''};
        ptags = {''};
    end
    
    % Render the popup
    h.popup(i) = uicontrol(hFig, ...
        'style', 'popupmenu', ...
        'position', popPos, ...
        'String', strs, ...
        'tag', tag, ...
        'Interruptible', 'Off', ...
        'Enable', enabState, ...
        'Visible', visState, ...
        'HorizontalAlignment', 'Left', ...
        'Callback', {cbs.popup, this}, ...
        'userdata', ptags);
    
    set(h.radio(i),'Tag',tag,'String',str);
end

set(this, 'Handles', h);

% Update the radio buttons
update(this);

l = [ ...
        handle.listener(this, 'NewSelection', {@listeners, 'selection_listener'}) ...
        handle.listener(this, 'NewSubSelection', {@listeners, 'subselection_listener'}) ...
        handle.listener(this, this.findprop('DisabledSelections'), ...
        'PropertyPostSet', {@listeners, 'disabledselections_listener'}) ...
        handle.listener(this, this.findprop('Identifiers'), ...
        'PropertyPostSet', {@listeners, 'identifiers_listener'}) ...
        handle.listener(this, this.findprop('Strings'), ...
        'PropertyPostSet', {@listeners, 'strings_listener'}) ...
        handle.listener(this, this.findprop('CSHTags'), ...
        'PropertyPostSet', {@listeners, 'cshtags_listener'}) ...
    ];

set(l, 'CallbackTarget', this);

set(this,'WhenRenderedListeners',l);

% ----------------------------------------------------------------
function [frPos, ctrlPos, msg] = parse_inputs(this, varargin)

hFig    = -1;
frPos   = {};
ctrlPos = {};
msg     = nargchk(1,4,nargin);

% Parse the inputs
for i = 1:length(varargin)
    if all(ishghandle(varargin{i})) && length(varargin{i}) == 1,
        hFig = varargin{i};
    elseif isnumeric(varargin{i}) & iscell(frPos),
        frPos = varargin{i};
    elseif isnumeric(varargin{i})
        ctrlPos = varargin{i};
    else
        msg = [varargin{i} ' is an invalid input.'];
    end
end

% Verify that the position vector is valid.
if iscell(frPos),
    frPos = [10 10 202 160];
elseif length(frPos) ~= 4 && ~isempty(frPos),
    msg = ['[' num2str(frPos) '] is not a valid position vector.'];
end

if isempty(ctrlPos)
    ctrlPos = frPos;
elseif length(ctrlPos) ~= 4 | any(ctrlPos <= 0),
    msg = ['[' num2str(ctrlPos) '] is not a valid position vector.'];
end

% If hFig is still -1 we need to get it from the object.
if ~ishghandle(hFig)
    hFig = get(this,'FigureHandle');
    if ~ishghandle(hFig), hFig = gcf;end
end

% If hFig is not -1, it must have been an input.  Save it in the object
set(this,'FigureHandle', hFig);


% --------------------------------------------------------
function width = getpopupwidth(strings)

string = {};

for i = 1:length(strings)
    if iscell(strings{i}),
        string = {string{:}, strings{i}{:}};
    end
end

width = largestuiwidth(string,'popup');


% --------------------------------------------------------
function width = getradiowidth(this)

strings = get(this, 'Strings');

string = {};

for i = 1:length(strings)
    if iscell(strings{i}),

        % If the length of the strings and the tags are the same, use it
        if ~difference(this, i),
            string = {string{:}, strings{i}{1}};
        end
    else
        string = {string{:}, strings{i}};
    end
end

width = largestuiwidth(string);

% --------------------------------------------------------
function rbtweak = gettweak(this)

% returns the extra rbtweak necessary to render the popups without covering
% radio button's label

strings = get(this, 'Strings');
string = {};

for i = 1:length(strings)
    
    if iscell(strings{i}) & ~difference(this, i),
        string{end+1} = strings{i}{1};
    end
end

if isempty(string),
    rbtweak = 0;
else
    rbtweak = largestuiwidth(string);
end

% [EOF]

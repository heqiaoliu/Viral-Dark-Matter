function listeners(this, eventData, fcn, varargin)
%LISTENERS Listeners to the properties of the selector

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.8 $  $Date: 2008/05/31 23:28:16 $

feval(fcn, this, eventData, varargin{:});


%------------------------------------------------------------------
function cshtags_listener(this, eventData)
%CSHTAGS_LISTENER Listener to the disabled selections property

update(this, 'update_cshtags');

%------------------------------------------------------------------
function disabledselections_listener(this, eventData)
%DISABLEDSELECTIONS_LISTENER Listener to the disabled selections property

update(this, 'update_enablestates');


%------------------------------------------------------------------
function identifiers_listener(this, eventData)
%IDENTIFIERS_LISTENER Listener to the identifiers property

tags = get(this, 'Identifiers');
h    = get(this, 'Handles');

% Loop through the tags because we don't know which one changed.
for i = 1:length(tags)
    
    if iscell(tags{i})
        set(h.radio(i), 'Tag', tags{i}{1});
        
        % The 1st tag is used for the Selection as the tag of the radio and popup
        set(h.popup(i), 'Tag', tags{i}{1}, 'UserData', {tags{i}{2:end}});
    else
        set(h.radio(i), 'Tag', tags{i});
    end
end

% If the current subselection doesn't match
subs = getsubselections(this);
if ~any(strcmpi(this.SubSelection, subs))
    if isempty(subs),
        set(this, 'privSubSelection', '');
    else
        set(this, 'privSubSelection', subs{1});
    end
end
% strings_listener(this);

%------------------------------------------------------------------
function selection_listener(this, eventData);
%SELECTION_LISTENER Listener to the Selection property

update(this, 'update_radiobtns');


%------------------------------------------------------------------
function subselection_listener(this, eventData)
%SUBSELECTION_LISTENER Listener to the subselection property

update(this, 'update_popup');


%------------------------------------------------------------------
function strings_listener(this, eventData)
%STRINGS_LISTENER Listener to the strings property

strs = get(this, 'Strings');
tags = get(this, 'Identifiers');
h    = get(this, 'Handles');

% Loop through the strings, since we don't know which one changed
for i = 1:length(strs)
    if iscell(strs{i})
        if difference(this, i)
            set(h.radio(i), 'String', '');
            popstr = strs{i};
        else
            set(h.radio(i), 'String', strs{i}{1});
            popstr = strs{i}(2:end);
        end
        visState = this.Visible;
    else
        set(h.radio(i), 'String', strs{i});
        visState = 'Off';
        popstr   = {''};
    end
        
    % Make sure that the value is still in the range.
    if get(h.popup(i), 'Value') > length(popstr),
        set(h.popup(i), 'Value', 1);
    end
    
    set(h.popup(i), 'String', popstr, 'Visible', visState);
end

resize_all_popup(this);
update(this, 'update_popup');

% ---------------------------------------------------------------------------
%
%                      Utility Functions
%
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
function resize_all_popup(this)

h     = get(this, 'Handles');

% If the frame is not rendered then we have nothing to base the resize on.
if isempty(h.frame), return; end

sz    = gui_sizes(this);

% Get the new largest uiwidth.
strings  = getstrings(h.popup);
newwidth = largestuiwidth(strings) + sz.rbwTweak;

origUnits = get(h.frame(1), 'Units'); set(h.frame(1), 'Units', 'Pixels');
framePos  = get(h.frame(1), 'Position'); set(h.frame(1), 'Units', origUnits);
origUnits = get(h.popup(1), 'Units'); set(h.popup(1), 'Units', 'Pixels');
popPos    = get(h.popup(1), 'Position'); set(h.popup(1), 'Units', origUnits);

% Make sure that the new largest width is inside the frame
if popPos(1) + newwidth > framePos(1) + framePos(3) - sz.hfus,
    newwidth = framePos(3) + framePos(1) - popPos(1) - sz.hfus;
end

if newwidth > popPos(3),
    
    h = get(this, 'Handles');
    
    % Loop over the popups and set all their widths
    for indx = 1:length(h.popup)
        origUnits = get(h.popup(indx), 'Units'); set(h.popup(indx), 'Units', 'Pixels');
        pos = get(h.popup(indx), 'Position');
        pos(3) = newwidth;
        set(h.popup(indx), 'Position', pos, 'Units', origUnits);
    end
end

% ---------------------------------------------------------------------------
function strs = getstrings(hpop)

strs = get(hpop, 'String');

if ~iscell(strs), strs = {strs}; end

if ~iscellstr(strs),
    for i = 1:length(strs)
        strs{i} = strs{i}';
    end
    strs = [strs{:}];
    strs = strs(:);
end


% [EOF]

function varargout = fvtool(this)
%FVTOOL   Launch FVTool against the selected filters.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 19:04:18 $

[Hd, normState] = lclgetfilters(this, this.SelectedFilters);

hfvt = fvtool(Hd, 'NormalizedFrequency', normState);

schema.prop(hfvt, 'ManagerLink', 'on/off');

set(hfvt, 'ManagerLink', 'On');

load private/fatoolicons;

% Find the toolbar of FVTool and add two buttons.
htoolbar = findobj(hfvt, 'type', 'uitoolbar');
htoolbar = htoolbar(end);

link.h.button = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@fullview_link_cb, hfvt, this}, ...
    'State', 'On', 'TooltipString', 'Link', ...
    'Separator','On', 'CData', icons.link, 'Tag', 'managerlink');

l = [ ...
        handle.listener(this, this.findprop('SelectedFilters'), ...
        'PropertyPostSet', {@selectedfilters_listener, hfvt}); ...
        handle.listener(this, 'NewData', {@selectedfilters_listener, hfvt}); ...
        handle.listener(this, 'ObjectBeingDestroyed', {@obd_listener, hfvt}); ...
    ];
set(l, 'CallbackTarget', this);
setappdata(hfvt, 'filtermanager_listener', l);

if nargout
    varargout = {hfvt};
end

% -------------------------------------------------------------------------
function [Hd, normState] = lclgetfilters(this, sfIndex)

Hd = getfilters(this, sfIndex);

allFs = get(Hd, 'Fs');
if iscell(allFs)
    allFs = [allFs{:}];
end

% If we are missing Fs from any filter, do not use any Fs at all.
if length(allFs) ~= length(Hd)
    normState = 'on';
    set(Hd, 'Fs', []);
else
    normState = 'off';
end

% -------------------------------------------------------------------------
function fullview_link_cb(hcbo, eventStruct, hfvt, this)

load private/fatoolicons;

if strcmpi(hfvt.ManagerLink, 'On')
    link = 'off';
    icon = icons.unlink;
else
    link = 'on';
    icon = icons.link;
end

set(hfvt, 'ManagerLink', link);
set(hcbo, 'CData', icon);

selectedfilters_listener(this, [], hfvt);

% -------------------------------------------------------------------------
function selectedfilters_listener(this, eventData, hfvt)

if strcmpi(hfvt.ManagerLink, 'On')
    [Hd, normState] = lclgetfilters(this, this.SelectedFilters);
    set(hfvt, 'Filters', Hd, 'NormalizedFrequency', normState);
end

% -------------------------------------------------------------------------
function obd_listener(this, eventData, hfvt)

delete(findprop(hfvt, 'ManagerLink'));

delete(findobj(hfvt, 'tag', 'managerlink'));

% [EOF]

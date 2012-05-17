function newselection_eventcb(this, eventData)
%NEWSELECTION_EVENTCB 

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2009/01/20 15:36:22 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores a vector of handles of winspecs objects
s = get(eventData, 'Data');
selectedwin = s.selectedwindows;

% Get the names of the selected windows
winnames = get(selectedwin, 'Name');
if ~iscell(winnames),
    winnames = {winnames};
end

% Set the names of selected windows in the combobox
index = [];
if ~isempty(s.currentindex),
    index = find(s.currentindex == s.selection);
end

if isrendered(this)
    l = find(this.WhenRenderedListeners, 'SourceObject', findprop(this, 'isModified'));
else
    l = [];
end
set(l, 'Enabled', 'Off');

set_selectednames(this, winnames, index);
selectedwin = selectedwin(index);
if ~isempty(selectedwin)
    setstate(this, getstate(selectedwin));
end

set(l, 'Enabled', 'On');

% [EOF]

function setselectmode(h,thismode)

% Copyright 2004 The MathWorks, Inc.

%% Set all the time plots to the new state and update all theirr button states
 
%% Clear any old selections
if ~isempty(h.Responses)
    h.Responses.View.selectedpoints = [];
end

%% Set the new state
h.State = thismode;
if strcmp(thismode,'None') 
    set(ancestor(h.axesgrid.parent,'figure'),'Pointer','arrow')
end

%% Lock out the normalization menu when any of the special modes are in
%% affect. The reason is that the current mechanism for drawing normalized
%% plots introduces a flicker during mouse actions in special modes. The
%% reason is that when in normalization mode the view draw method sets the
%% XData and YData of all the lines to empty, leaving it to the view
%% adjustview method to reset them to non-empty values. The result is a
%% flicker during data selection actions.
if ~strcmp(h.State,'None')
    set(h.AxesGrid.findMenu('normalize'),'Enable','off')
else
    set(h.AxesGrid.findMenu('normalize'),'Enable','on')
end

%% Refresh
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
h.draw
warning(S);


function setselectmode(h,thismode)

% Copyright 2004-2006 The MathWorks, Inc.

%% Set all the time plots to the new state and update all theirr button states

%% If no change - no-op
if strcmp(h.State,thismode)
    return
end

%% Clear any old selections
h.clearselect;

S = warning('off','all'); % Disable "Some data is missing ..."
h.AxesGrid.LimitManager='off';
h.draw
h.AxesGrid.LimitManager='off';
warning(S);

%% Set the new state
h.State = thismode;

%% Lock out the normalization menu when any of the special modes are in
%% affect. The reason is that the current mechanism for drawing normalized
%% plots introduces a flicker during mouse actions in special modes. The
%% reason is that when in normalization mode the view draw method sets the
%% XData and YData of all the lines to empty, leaving it to the view
%% adjustview method to reset them to non-empty values. The result is a
%% flicker during data selection actions.
if strcmp(thismode,'None') 
    % Resume normal event handling
    set(ancestor(h.AxesGrid.Parent,'figure'),'Interruptible','on','BusyAction','queue')
    set(ancestor(h.axesgrid.parent,'figure'),'Pointer','arrow')  
    set(h.AxesGrid.findMenu('normalize'),'Enable','on')
    %set(h.AxesGrid,'XlimMode','auto')
    h.AxesGrid.LimitManager = 'on';
    h.AxesGrid.send('viewchange')
else
    % Delete datatips for performance and de-select normalize 
    dcm = datacursormode(ancestor(h.AxesGrid.Parent,'figure'));
    dc = dcm.DataCursors;
    for k=1:length(dc)
        dcm.removeDataCursor(dc(k));
    end
    set(h.AxesGrid.findMenu('normalize'),'Enable','off')
end

%% Clear toolbar
cleartb(h.Parent,h.State);

%% Refresh
drawnow


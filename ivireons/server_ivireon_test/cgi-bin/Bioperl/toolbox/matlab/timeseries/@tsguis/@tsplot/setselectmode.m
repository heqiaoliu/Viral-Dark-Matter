function setselectmode(h,thismode)

% Copyright 2004-2005 The MathWorks, Inc.

%% Set all the time plots to the new state and update all their button states

%% If no change - no-op
if strcmp(h.State,thismode)
    return
end

%% Set the mode
h.State = thismode;
if strcmp(thismode,'None') 
    set(ancestor(h.axesgrid.parent,'figure'),'Pointer','arrow')
    set(ancestor(h.AxesGrid.Parent,'figure'), ...
          'WindowButtonDownFcn','',...    
          'WindowButtonUpFcn','')
    viewer = tsguis.tsviewer;
    if viewer.DataTipsEnabled
        set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn',@hoverfig);
    end
    for k=1:length(h.waves)
        h.waves(k).view.SelectedInterval = [];
    end
    S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
    h.draw
    warning(S);
end

%% Lock out the normalization menu when any of the special modes are in
%% affect. The reason is that the current mechanism for drawing normalized
%% plots introduces a flicker during mouse actions in special modes. The
%% reason is that when in normalization mode the view draw method sets the
%% XData and YData of all the lines to empty, leaving it to the view
%% adjustview method to reset them to non-empty values. The result is a
%% flicker during data selection actions. 
if ~strcmp(h.State,'None')
    % Delete datatips for performance and de-select normalize 
    dcm = datacursormode(ancestor(h.AxesGrid.Parent,'figure'));
    dc = dcm.DataCursors;
    for k=1:length(dc)
        dcm.removeDataCursor(dc(k));
    end
    set(h.AxesGrid.findMenu('normalize'),'Enable','off')
else
    set(h.AxesGrid.findMenu('normalize'),'Enable','on')
end

%% Clear toolbar
cleartb(h.Parent,h.State);

drawnow


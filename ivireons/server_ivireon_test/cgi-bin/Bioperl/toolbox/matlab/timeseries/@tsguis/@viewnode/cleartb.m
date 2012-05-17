function cleartb(h,state)

% Copyright 2004-2005 The MathWorks, Inc.

%% Releases all toolbar buttons not associated with the specific state

%% Find the toolbar buttons
thisbutton = findobj(h.Handles.ToolbarBtns,'Tag',state);

%% Popup all custom toolbar buttons for this figure
for k=1:length(h.Handles.ToolbarBtns)
    if ~isequal(h.Handles.ToolbarBtns(k),thisbutton)
        set(h.Handles.ToolbarBtns(k),'State','off')
    end
end

%% Make sure it's selected
set(thisbutton,'State','on') 

%% Popup all HG toolbar buttons for this figure
if ~strcmp(state,'None') 
    pan(h.Figure,'off')
    zoom(h.Figure,'off')
    plotedit(h.Figure,'off')
    % Work around automatic selection of the figure in the property editor
    if ~isempty(h.Plot) && ishandle(h.Plot)
        selectobject(h.Plot.axesgrid.parent);
    end
end
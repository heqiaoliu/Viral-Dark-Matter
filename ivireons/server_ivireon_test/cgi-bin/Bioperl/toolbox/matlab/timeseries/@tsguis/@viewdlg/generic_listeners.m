function generic_listeners(h)

% Copyright 2004-2008 The MathWorks, Inc.

%% Dialog visibility listener
h.Listeners = [h.Listeners; ...
    handle.listener(h,h.findprop('Visible'),'PropertyPostSet', ...
    {@localVisibilityCallback h})];

%% Viewnode listener for changes in the current view node
h.Statelisteners.ViewNode = handle.listener(h,...
    h.findprop('ViewNode'),'PropertyPostSet',{@localViewNodeChange h});

%% Parentview node listeners to keep the view combo updates
h.Parentviewnode = h.viewnode.up.up;
viewhostnodes = h.Parentviewnode.getChildren;
for k=1:length(viewhostnodes)
    h.Listeners = [h.Listeners; ...
        handle.listener(...
           viewhostnodes(k),'viewcontentschange',{@localUpdateViews h});
        handle.listener(...
           viewhostnodes(k),'ObjectChildAdded',{@localUpdateViews h});
        handle.listener(...
           viewhostnodes(k),'ObjectChildRemoved',{@localUpdateViews h})];
end      

%% Fire listeners
localUpdateViews([],[],h)
localViewNodeChange([],[],h)


function localUpdateViews(eventSrc,eventData,h)

%% Callback to sibling view nodes being added or deleted.

viewNodes = h.Parentviewnode.find('-isa',h.Nodeclass);
if ~isempty(eventData) && strcmp(eventData.Type,'ObjectChildRemoved')
    viewNodes = setdiff(viewNodes,eventData.Child);
end
if length(viewNodes)>0
    
    %% If the current view has gone, reset the current view to the first
    %% available viewNode
    if isempty(h.ViewNode) || ~ishandle(h.ViewNode) || isempty(find(h.Viewnode==viewNodes)) 
        h.ViewNode = viewNodes(1); 
    end 
    
    % Update the dialog to reflect now view list
    h.updateviews(viewNodes);        
else % All view nodes have been deleted or have no timeplots - close the dialog
    h.ViewNode = [];
    h.Visible = 'off';
end

function localViewNodeChange(eventSrc, eventData, h)

%% Callback for the ViewNode property listener which maintains a 
%% listener to time series being added or removed from the current view

%% Reset the ViewNode tschanged listener to reflect the new viewNode
if ~isempty(h.ViewNode) && ishandle(h.ViewNode)
    h.Statelisteners.Members = handle.listener(h.Viewnode,...
           'tschanged',@(es,ed) update(h));
end

%% Sync the dialog to the new viewnode if the Plot has been created
h.update  

%% Select the new node in the view combo
if ~isempty(h.ViewNode) && ishandle(h.ViewNode)
    newPos = find(h.ViewNode==get(h.Handles.COMBOselectView,'UserData'));
    if ~isempty(newPos)
        set(h.Handles.COMBOselectView,'Value',newPos)
    end
end

function localVisibilityCallback(es,ed,h)

%% Visibility callback
if ~isempty(h.Figure) && ishghandle(h.Figure)
    set(h.Figure,'Visible',get(h,'Visible'))
    % Work around a MAC rendering problem where the color
    % of the figure remains a light gray native default when the
    % figure visibility is turned on by listeners.
    if strcmp(computer,'MAC')
        pause(0.2)
    end
end
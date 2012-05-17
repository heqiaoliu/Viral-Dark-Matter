function paste(this,manager)

% Copyright 2004-2006 The MathWorks, Inc.

%% Paste context menu callback

%% Copy the view in the cliboard and give it a name which is unquie
%% to its parent

%% Only viewnodes can be pasted
if ~isa(manager.Root.Tsviewer.Clipboard,'tsguis.viewnode')
    return
end

%% Create a new view
newview = this.addplot(manager);

%% Name the new view
siblingnames = get(this.getChildren,{'Label'});
newviewname = sprintf('Copy_of_%s',manager.Root.Tsviewer.Clipboard.Label);
k = 1;
while any(strcmp(newviewname,siblingnames))
    newviewname = sprintf('Copy_of_%d_%s',k,manager.Root.Tsviewer.Clipboard.Label);
    k = k+1;
end   

%% Add the time series from the pasted view to the target view
P = manager.Root.Tsviewer.Clipboard.Plot;
ts = {};
if ~isempty(P) && ishandle(P)
    ts = P.getTimeSeries;
    for k=1:length(ts)
        newview.addTs(ts{k});
    end
end
if isempty(ts) % Make empty fig visible and dock it 
    set(newview.Figure,'Visible','on');
    if ~isempty(manager.Root.Tsviewer.MDIGroupName)
        set(ancestor(newview.Figure,'Figure'),'WindowStyle','docked')
    end
end

%% Clear the lock on the tree
manager.reset

%% Select the new node
manager.Tree.setSelectedNode(newview.getTreeNodeInterface)   
drawnow % Force the selection
manager.Tree.repaint
newview.Label = newviewname; % Must be changed after addTs so listeners can update fig title

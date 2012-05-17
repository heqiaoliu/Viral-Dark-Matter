function state_listeners(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Add view node children listeners
h.addListeners([handle.listener(h,'ObjectChildAdded',{@localUpdateContents h});...
                handle.listener(h,'ObjectChildRemoved',{@localUpdateContents h})])
localUpdateContents([],struct('Type',[]),h)

function localUpdateContents(es,ed,h)

%% Create a listener to monitor any changes in the member time series of
%% each view. 
delete(h.TstableListener);
h.TstableListener = [];
views = h.getChildren;
if strcmp(ed.Type,'ObjectChildRemoved')
    views = setdiff(views,ed.Child);
end
if length(views)>0
    h.TstableListener = [handle.listener(views,'tschanged',{@localsendviewevent h});...
                         handle.listener(views,views(1).findprop('Label'), ...
                             'PropertyPostSet',{@localnodenamechange h})];
end

%% Update the viewstable
if strcmp(ed.Type,'ObjectChildRemoved')
    viewstable(h,ed.Child);
else
    viewstable(h);
end

%% Update the view combo boxes
%% If a node is being deleted, exclude it from the list
if ~isempty(ed) && strcmp(ed.Type,'ObjectChildRemoved')
    nodelist = setdiff(h.getChildren, ed.Child);
else
    nodelist = h.getChildren;
end

function localsendviewevent(es,ed,h)

h.send('viewcontentschange')

%% Update timeseries table if the contents of this view has changed
selRow = h.Handles.viewsTable.getSelectedRow+1;
if selRow>0
    viewTableData = cell(h.Handles.viewsTable.getModel.getData);
    selectedView = h.getChildren('Label',viewTableData{selRow,1});
    if ~isempty(es)
        if ed.Source==selectedView
           % Refresh the time series table for the selected view since it has
           % changed
           tstable(h,selectedView)
        end
    end
end

viewstable(h);


function localnodenamechange(es,ed,h)

%% Callback for view node renaming
h.send('viewcontentschange')
viewstable(h);
%localupdateviewcombos(h.getChildren)

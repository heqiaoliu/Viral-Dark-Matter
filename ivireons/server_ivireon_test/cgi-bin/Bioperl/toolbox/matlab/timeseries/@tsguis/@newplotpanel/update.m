function update(h,manager,eventData)

%   Author(s): James Owen
%   Copyright 2004-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $ $Date: 2008/12/29 02:11:19 $

%% Callback to Viewnode ObjectChildAdded ObjectChildDeleted. Keeps the 
%% existing view combo synronized with the list of views.

if ~ishghandle(manager.figure) % Being closed
    return
end

viewlist = setdiff(manager.Root.TsViewer.ViewsNode.find('-depth',2),...
    manager.Root.TsViewer.ViewsNode.find('-depth',1));

%% If a node is being deleted, exclude it from the list
if ~isempty(eventData) && strcmp(eventData.Type,'ObjectChildRemoved')
    viewlist = setdiff(viewlist, eventData.Child);
end

%% Update the combo box with the list of current @viewnodes
if ~isempty(viewlist)
    set(h.Handles.COMBexistview,'Enable','on','String',...
        get(viewlist,{'Label'}),'Value',1);
    set(h.Handles.RADIOexist,'Enable','on')
else
    set(h.Handles.COMBexistview,'String',{' '},'Enable','off');
    set(h.Handles.RADIOexist,'Enable','off')
    set(h.Handles.RADIOexist,'Value',false)
    set(h.Handles.RADIOnew,'Value',true)
end     

%% Update the new view edit box to it does not overlap with an existing
%% view name
k = 1;
while any(strcmp(sprintf('View%d',k),get(viewlist,{'Label'})))
    k=k+1;
end
set(h.Handles.EDITnewview,'String',sprintf('View%d',k));
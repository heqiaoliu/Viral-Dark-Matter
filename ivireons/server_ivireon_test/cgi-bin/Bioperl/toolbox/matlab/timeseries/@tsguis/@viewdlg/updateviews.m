function updateviews(h, viewNodes)

% Copyright 2004 The MathWorks, Inc.

%% Unpdates the dialog to reflect a change in the list of views

newviewList = cell(1,length(viewNodes));
for k=1:length(viewNodes)
    if isa(viewNodes(k),h.Nodeclass) && ~isempty(viewNodes(k).up)
        newviewList{k} = sprintf('%s:%s',viewNodes(k).up.Label,viewNodes(k).Label);
    end
end

if ~isempty(h.ViewNode) && ishandle(h.ViewNode)
    newPos = find(h.ViewNode==viewNodes);
    set(h.Handles.COMBOselectView,'String',newviewList,'Value',newPos,...
        'Userdata',viewNodes);
end
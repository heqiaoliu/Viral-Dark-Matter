function draw(h,I)

selectionHandles = h.SelectionHandles;
if nargin>1
    h.SelectionHandles = feval(h.BehaviorObject.DrawFcn{1},I,...
        h.BehaviorObject.DrawFcn{2:end});
end

if isempty(selectionHandles)
    set(h.SelectionHandles,'Tag','Brushing')
    h.addContextMenu;
    h.addBehaviorObjects;
end
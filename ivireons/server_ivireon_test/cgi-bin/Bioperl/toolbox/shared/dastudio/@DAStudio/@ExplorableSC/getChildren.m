function children = getChildren(this)
% Copyright 2005 The MathWorks, Inc.

children = recursiveGetChildren(this, this.Recursive);
children = filter(children);

%% recursively calculate the connected children in the UDD tree
function children = recursiveGetChildren(obj, recursive)

children = [];

if isempty(obj)
    return;
end

current  = obj.down;

while ~isempty(current)
    children = [children current];

    if recursive
        children = [children recursiveGetChildren(current, recursive)];
    end
        
    current  = current.right;
end

%% filter the objects to only those held by the root ExplorableSC
function filteredChildren = filter( rawChildrenSC )

filteredChildren = [];

if isempty(rawChildrenSC)
    return;
end

root = getRoot( rawChildrenSC(1) );

if ~isempty(root.Children)
    for i = 1:length(rawChildrenSC)
        rawChildren(i) = rawChildrenSC(i).getForwardedObject;
    end
    
    filteredChildren = intersect(root.Children, rawChildren);
end

%% helpers
function root = getRoot( obj )
if isempty( obj.getParent )
    root = obj;
else
    root = getRoot( obj.getParent );
end

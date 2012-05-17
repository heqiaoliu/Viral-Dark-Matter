function h = daexplore(objects, properties, visible, hReuse)
% Copyright 2005, 2008 The MathWorks, Inc.

%% error checking
switch nargin
    case 1
        properties = {};
        visible = true;
        hReuse = [];
    case 2
        visible = true;
        hReuse = [];
    case 3
        hReuse = [];
    otherwise
        % MATLAB catches case of too many arguments.
        % Other errors are caught by the statement below.
end

if ~isa(objects, 'DAStudio.Object') || ~iscell(properties)
    error('DAStudio:DAExplore:DAStudioObjectAndCellRequired', ...
          'Input arguments must be a DAStudio.Object array and a cell array of property names');
end

%% parameter initialization
explorerName  = 'List Explorer';
explorerProps = 'List Properties';
explorerUD    = struct;

%% create the root object for this explorer instance
root = getExplorableRoot(objects);

%% create an invisible explorer and initialize it or reuse an existing instance
if isempty(hReuse)
    h = DAStudio.Explorer(root, explorerName, false);
    m = DAStudio.ActionManager;
    m.initializeClient(h);

    % let this explorer instance hold onto some properties
    p = schema.prop(h, 'Properties', 'string vector');
    h.Properties = properties;
    
    r = schema.prop(h, 'Recursive', 'bool');
    h.Recursive  = true;

    % let this explorer instance hold onto some listeners
    explorerUD.Root               = root;
    explorerUD.CloseListener      = handle.listener(h, 'MEPostClosed', @closeHandler);
    explorerUD.DeleteListener     = handle.listener(h, 'MEDelete', @closeHandler);
    explorerUD.PropertiesListener = handle.listener(h, p, 'PropertyPostSet', {@propertiesHandler, h});
    explorerUD.RecursiveListener  = handle.listener(h, r, 'PropertyPostSet', {@recursiveHandler, h});
    explorerUD.ChildrenListener   = handle.listener(root, findprop(classhandle(root), 'Children'), 'PropertyPostSet', {@childrenHandler, h});
    h.UserData                    = explorerUD;

    % List Explorer customization
    h.title = explorerName;
    h.showTreeView(false);
    h.showContentsOf(false);
    h.setListProperties(properties);

    imh = DAStudio.imExplorer(h);
    imh.selectListViewNode(objects(1));

    % show the explorer to the user for the first time
    if visible
        h.show;
    end
    
else
    hReuse.setRoot(root);
    
    hReuse.UserData.Root             = root;
    hReuse.UserData.ChildrenListener = handle.listener(root, findprop(classhandle(root), 'Children'), 'PropertyPostSet', {@childrenHandler, hReuse});    
    
    hReuse.setListProperties(properties);

end

end % function daexplore


%% calculate the least common ancestor tree
function [root pool] = getExplorableRoot(objects)

pool = {};
root = [];
tree = createMinimumSpanningTree(objects);

if isempty(tree)
    root = DAStudio.Explorable;
    root.Children = objects;
else
    root = getLeastCommonAncestor(tree, objects);
    root.Children = objects;
end

    function lca = getLeastCommonAncestor(root, objects)
    
        lca = [];
        
        % if the proposed root is in the list of interest, it is the lca
        obj = root.getForwardedObject;
        if ~isempty( intersect(obj, objects ) )
            lca = root;
        end

        if isempty(lca)
            % the proposed root is the lca if it branches or its immediate
            % child is in the list of interest
            child = root.down;
            isLCA = isempty(child)        || ...
                    ~isempty(child.right) || ...
                    ~isempty( intersect(child.getForwardedObject, objects) );

            if isLCA
                lca = root;
            else
                lca = getLeastCommonAncestor(child, objects);
            end
        end
        
        lca.disconnect;

    end %function getLeastCommonAncestor

    function root = createMinimumSpanningTree(objects)

        root = [];
        
        %special case: if there is only one object
        %and it doesn't have a parent, then we dont
        %need to determine a root
        if length(objects) == 1
            if(isempty(objects(1).up))
                return;
            end
        end

        for i = 1:length(objects)
            parent  = objects(i);
            childSC = [];
            while ~isempty(parent)
                object  = findInPool(parent);
                if isempty(object)
                    parentSC = DAStudio.ExplorableSC(parent);
                    if ~isempty(childSC)
                        parentSC.connect(childSC, 'down');
                    end
                    pool{end+1} = parentSC;

                    if isempty(parent.up)
                        if isempty(root)
                            root = parentSC;
                        elseif root ~= parent
                            % objects are not nodes in a rooted tree
                            pool = {};
                            root = [];
                            return;
                        end
                    end

                    childSC = parentSC;
                    parent  = parent.up;
                else
                    if ~isempty(childSC)
                        object.connect(childSC, 'down');
                    end
                    break;
                end
            end

        end

    end % function createMinimumSpanningTree

    function found = findInPool(parent)

        found = [];

        for i = 1:length(pool)
            if parent == pool{i}.getForwardedObject
                found = pool{i};
                break;
            end
        end

    end % function findInPool

end % function getExplorableRoot


%% event handlers ---------------------------------------------------------
function closeHandler(h, e, varargin)
if ~ishandle(h.getRoot)
    return;
end

h.getRoot.delete;
end

function childrenHandler(h, e, explorer, varargin)
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ListChanged');
end

function propertiesHandler(h, e, explorer, varargin)
explorer.setListProperties(e.NewValue);
end

function recursiveHandler(h, e, explorer, varargin)
recursiveSet(explorer.getRoot, e.NewValue);
ed = DAStudio.EventDispatcher;
ed.broadcastEvent( 'HierarchyChangedEvent', explorer.getRoot );
end

function recursiveSet(h, val)
if isempty(h), return, end
h.Recursive = val;
c = h.down;
while ~isempty(c)
    recursiveSet(c, val);
    c = c.right;
end
end

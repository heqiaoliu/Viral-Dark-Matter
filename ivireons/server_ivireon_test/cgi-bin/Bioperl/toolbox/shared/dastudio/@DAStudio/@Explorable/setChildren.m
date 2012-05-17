function children = setChildren(this, children)
% the sole purpose of this setter function is to create necessary listeners
% on the incoming objects so that the DAStudio.Explorable object can remain
% in sync with its childrens' lifespan

% Copyright 2005 The MathWorks, Inc.

childListeners  = {};
parentListeners = {};
parents         = {};

if isempty(children)
    % remove previous listeners
    this.Listeners = [];
else
    % we will listen to events triggered from the parent so add listeners
    % only to those child objects that do not have a parent
    for i = 1:length(children)
        if isempty(children(i).getParent)
            childListeners{end+1} = handle.listener(children(i),...
                                                    'ObjectBeingDestroyed',...
                                                    {@childDestroyedHandler, this});
        else
            parents{end+1} = children(i).getParent;
        end
    end
    
    parents = unique([parents{:}]);
    for i = 1:length(parents)
        parentListeners{end+1} = handle.listener(parents(i),...
                                                 'ObjectBeingDestroyed',...
                                                 {@parentDestroyedHandler, this});
        parentListeners{end+1} = handle.listener(parents(i),...
                                                 'ObjectChildRemoved',...
                                                 {@childRemovedHandler, this});
    end
    
    this.Listeners = [childListeners{:} parentListeners{:}];
end


%% Event handlers ---------------------------------------------------------
function childDestroyedHandler(h, e, root, varargin)
root.Children = root.Children(ishandle(root.Children));

function childRemovedHandler(h, e, root, varargin)
c = root.Children;
for i = 1:length(c)
    if c(i) == e.Child
        c(i) = [];
        break;
    end
end
root.Children = c(ishandle(c));

function parentDestroyedHandler(h, e, root, varargin)
root.Children = root.Children(ishandle(root.Children));

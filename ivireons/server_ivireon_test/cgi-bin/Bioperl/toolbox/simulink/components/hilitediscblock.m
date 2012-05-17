function varargout = hilitediscblock(item, hilite, children, childrenhilite, forceopen)
%HILITEDISCBLOCK highlights Simulink item.
%	HILITEDISCBLOCK(ITEM, HILITE,CHILDREN,CHILDRENHILITE,FORCEOPEN) Selects or highlights ITEM.
%
%   HILITE -- 0: turn off hilite
%             1: hilite with 'different' scheme
%             2: hilite with 'unique' scheme
%             3: hilite with 'none' scheme
%   FORCEOPEN -- 1: force ITEM visible
%                0: leave ITEM as is

% $Revision: 1.5.4.4 $ $Date: 2008/12/01 07:47:40 $
% Copyright 1990-2006 The MathWorks, Inc.

hasBeenDiscretized = 0;
sampleTime         = -1.0;
transMethod        = 'unknown';

% total number of discretized blocks of entire tree
totalRootTrans = 0;

% total number of discretized blocks in current selected node
totalTrans = 0;

if (~isempty(item))
    
    try
        root = bdroot(item); % get tree root node
        % get all children of tree root at top level
        children_root = find_system(root,'LookUnderMasks','None','SearchDepth',1);
        num_children = length(children_root);
        % total number of discretized blocks on the root level
        totalChildrenTrans = zeros(num_children,1);

        dirtyflag = get_param(bdroot(item), 'dirty');

        % going through all blocks in current selection, calculate the number of discretized blocks and hilite them
        [hasBeenDiscretized, sampleTime, transMethod, totalTrans]  = hiliteItem(item, hilite, children, childrenhilite, forceopen);

        % if item is root, only need to process it once
        if ~strcmp(item, root)
            % going through all blocks of entire tree, calculate the total number of discretized blocks
            % exclude children_root(1) which represents the model
            for i = 2:num_children

                % skip the child which was processed in previous hiliteItem
                % function
                if strcmp(children_root(i), item)
                    totalRootTrans = totalRootTrans + totalTrans;
                    continue
                end
                totalChildrenTrans(i) = hiliteChildren(children_root(i), 0, false);
                if( totalChildrenTrans(i) > 0)
                    totalRootTrans = totalRootTrans + totalChildrenTrans(i);
                end
            end
        else 
            totalRootTrans = totalTrans;
        end

        newdirtyflag = get_param(bdroot(item), 'dirty');
        if ~strcmpi(dirtyflag, newdirtyflag)
            set_param(bdroot(item), 'dirty', dirtyflag);
        end
    catch

    end
end

% output
varargout{1} = hasBeenDiscretized;
varargout{2} = sampleTime;
varargout{3} = transMethod;
varargout{4} = totalTrans;
varargout{5} = totalRootTrans;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HILITEMDITEM highlight Simulink item.
%	HILITEMDITEM(ITEM1, HILITE, CHILDREN) Selects or highlights ITEM
%      along with all sepcified children
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   [hasBeenDiscretized, sampleTime, transMethod, totalTrans]  = hiliteItem(item, hilite, children, childrenhilite, forceopen)
hasBeenDiscretized = 0;
sampleTime         = -1;
transMethod        = 'unknown';
totalTrans         = 0;
if strcmp(get_param(item,'type'),'block_diagram')
    itemType = 'block_diagram';
else
    if strcmpi(get_param(item,'blocktype'),'SubSystem') & strcmpi(get_param(item,'mask'),'off')
        itemType = 'SubSystem';
    else
        itemType = 'block';
    end
    [sampleTime, transMethod] = getItemInfo(item, sampleTime, transMethod);
end

%-----------------------------------------------------------------------------------------------------------
switch itemType

  case 'block_diagram'
    window 		      = findSystemWindow(item);	            % Find an open system window in the model.
    if (forceopen)
        if (isempty(window))       % No subsystem window is open.
            open_system(item);
        elseif (~strcmp(item, window))
            open_system(item, window, 'browse', 'force');
        end
    end

    % going through all children, calculate number of discretized blocks
    % in each child and hilite each child. The reason of processing each child
    % separately is for the special handling of the child who is discretized
    % by replace with configurable subsystem
    totalTrans = 0;
    for i = 1:length(children)
        childTrans(i) = hiliteChildren(children(i), 0, true);
        totalTrans = totalTrans + childTrans(i);
        % hilite subsystem
        if( childTrans(i) == 0)
            hilite_system(children(i), 'red');
        else
            hilite_system(children(i), 'blue');

            %special handling of subsystem discretizd by replace with
            %Configurable subsystem, where hilite subsystem will
            % erase privous hilite for its children, so need to rehilite
            % its discretized children
            grandchildren = find_system(children(i),'LookUnderMasks','None','SearchDepth',1);
            hilite_configsys_children(grandchildren);
        end
    end
    closeScopes(item);

  case 'SubSystem'
    parent              = get_param(item, 'parent');
    window            = findSystemWindow(item);             % Find an open system window in the model.
    if(forceopen)
        if (isempty(window))
            model           = bdroot(item);
            open_system(model);
            open_system(parent, model, 'browse', 'force');
        else
            open_system(parent, window, 'browse', 'force');
        end
    end

    % put selection mark first
   if (hilite)
      set_param(item, 'selected', 'on');
   else
      set_param(item, 'selected', 'off');
   end
   % The name of the children passed in from java code is the original block name 
   % which sometimes may be different from that of after discretization such as 
   % in the case of 'Replacing current selection with Configurable subsystem', 
   % so need to update the children
   children = find_system(item,'LookUnderMasks','None','SearchDepth',1);
   numCh = length(children);
   totalTrans = hiliteChildren(children(2:numCh), 0, true);
   
   % hilite subsystem 
   if( totalTrans == 0)
       hilite_system(item, 'red');
   else
       hilite_system(item, 'blue');
       
       %special handling of subsystem discretizd by replace with
       %Configurable subsystem, where hilite subsystem will
       % erase privous hilite for its children, so need to rehilite
       % its discretized children
       hilite_configsys_children(children);
   end
   closeScopes(parent);

    case 'block'
    parent              = get_param(item, 'parent');
    window              = findSystemWindow(item);             % Find an open system window in the model.
    if (forceopen)
        if (isempty(window))
            model             = bdroot(item);
            open_system(model);
            open_system(parent, model, 'browse', 'force');
        else
            open_system(parent, window, 'browse', 'force');
        end
    end

    % determine if the block has been discretized and hilite it accordingly
    [wasDiscretized, hilite_new] = get_new_hilite(item);

    if(wasDiscretized)
        totalTrans = 1;
    end

    hiliteType = getHiliteType(hilite_new);
    set_param(item, 'hiliteAncestors', hiliteType);
    
    % put selection mark
    if (hilite)
        set_param(item, 'selected', 'on');
    else
        set_param(item, 'selected', 'off');
    end
    closeScopes(parent);

end
% end switch itemtype -------------------------------------------------------------------------------

if totalTrans > 0
    hasBeenDiscretized = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find a open system window in the given hierarchy that is open.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function window = findSystemWindow(item)

window 				  = [];
parent			      = item;

while (~isempty(parent))
    window			  = find_system(parent, 'BlockType', 'SubSystem', 'open', 'on');
    if (isempty(window))
        window		      = find_system(parent, 'Type', 'block_diagram', 'open', 'on');
    end
    if (~isempty(window))
        window		      = window{1};
        break;
    end
    parent		      = get_param(parent, 'Parent');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close all open scopes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeScopes(subsystem)

scopeToClose        = find_system(subsystem, 'BlockType', 'Scope');
for i               = 1 : length(scopeToClose)                % Close all open scopes.
    figId             = get_param(scopeToClose{i}, 'figure');
    if (figId > 0)
        set(figId, 'visible', 'off');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hilite discretized children of subsystem discretized by replacment with 
% configurable subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hilite_configsys_children(children)

for j = 2:length(children)
    if ~strcmp(get_param(children{j},'linkstatus'),'none')
        child_config = find_system(children{j}, 'FollowLinks','on');
        for k = 2:length(child_config)
            totalTrans_config = hiliteChildren(child_config(k), 0, false);
            if totalTrans_config > 0
                hilite_system(child_config{k}, 'blue');
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hilite all children blocks for a subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function totalTrans = hiliteChildren(children, totalTrans, hiliteSystem)
% This function checks all children with the existing rule, and
% find out if they have been discretized, and hilite them accordingly

for i = 1 : length (children)

    child  = children{i};
    hilite{i} = 1;  % initialize

    % find all children in the case of SubSystem
    if strcmpi(get_param(child, 'blocktype'), 'SubSystem') == 1

        % when replace with configurable subsystem, the discretized blocks
        % are put into a link to the subsystem, follow link to access the
        % blocks
        if strcmp(get_param(child,'linkstatus'),'none')
             allBlks = find_system(child);
        else
            allBlks = find_system(child, 'FollowLinks','on');
        end

        % In the case of single block having 'SubSystem' as blocktype(usually after discretization)
        % no recursion needed, determine if wasDiscretized directly
        if length(allBlks) == 1
            [wasDiscretized, hilite{i}] = get_new_hilite(child);
            totalTrans = totalTrans + wasDiscretized;
        else
            % going through each children, then children's children... recursively calling
            % the function itself, calculate the total discretized number
            for j = 2:length(allBlks)
                totalTrans = hiliteChildren(allBlks(j), totalTrans, hiliteSystem);
            end
        end
    else
        [wasDiscretized, hilite{i}] = get_new_hilite(child);
        totalTrans = totalTrans + wasDiscretized;
    end

    % hilite the discretized block
    if(hiliteSystem)
        hiliteType = getHiliteType(hilite{i});
        set_param(child, 'hiliteancestors', hiliteType);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hiliteType = getHiliteType(hilite)
if hilite==2
    hiliteType = 'unique'; % blue color
elseif hilite==1
    hiliteType = 'different'; % red color
elseif hilite==3
    hiliteType = 'none';
else
    hiliteType = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abstract:
%    get new hilite in case all blocks have been discretized
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hasBeenDiscretized, hilite] = get_new_hilite(sys)
% Check the blocks in sys against existing rules and output
% if they have been discretized and the relative hilite type

hasBeenDiscretized = 0;
hilite = 1;
blks = find_system(sys);
isDiscretizable = [];
[theRules, theType, discFunctions] = rules('get_disc_functions');
foundDiscretizedBlock = 0;
len = length(blks);

% isDisc: isDiscretizable
% discFcn: discretize function
for j = 1:len
    [isDisc, discFcn] = chkrules(blks{j}, theRules);
    switch discFcn
      case discFunctions
        % deal with special case when discretized built-in blocks
        % if found, override isDisc
        % DiscreteTransferFcn is an exception to this, see special
        % following special handling 
        if(~foundDiscretizedBlock)
            mskType = get_param(blks{j},'MaskType');
            if(any(strcmp(discFunctions,mskType)))
                foundDiscretizedBlock = 1;
                isDisc = 1;
            end
            
            % special handling for discrete transfer function
            % This is needed in the case of s->z with replacement
            % method in z-domain. In this case:
            % get_param(block, 'mask') = off and
            % get_param(block, 'MaksType') = ''
            % get_param(block,'BlockType') = 'DiscreteTransferFcn'
            % Currently sldiscmdl only support DiscretizeTransferFcn
            blkType = get_param(blks{j},'BlockType');
            if(strcmp(blkType, 'DiscreteTransferFcn'))
                foundDiscretizedBlock = 1;
                isDisc = 1;
            end
        end
    end
    [isDiscretizable] = [isDiscretizable isDisc];
    
end

if(len == 1)
    if(foundDiscretizedBlock)
        hilite = 2;
        hasBeenDiscretized = 1;
    end
else
    if ~isempty(isDiscretizable)
        if(any(isDiscretizable))
            hilite = 2;
            hasBeenDiscretized = 1;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abstract
%    get sample time and method used by the block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sampleTime, transMethod] = getItemInfo(item, sampleTime, transMethod)

try
    sampleTime = str2num(get_param(item, 'SampleTime'));
end

failed = 0;
try
    methodUsed = get_param(item,'method');
catch
    failed = 1;
end

if(failed)
    try
        methodUsed = get_param(item,'MaskInitialization');
        % Removed '%'
        if(length(methodUsed) > 2)
            transformMethods = {'tustin','zoh','foh','prewarp','matched'};
            methodUsed = methodUsed(2:end);
            if(any(strcmp(transformMethods,methodUsed)))
                transMethod = methodUsed;
            end
        end
    end
else
    transMethod = methodUsed;
end

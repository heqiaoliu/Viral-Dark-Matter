function sync(dst,src,arg)
%SYNC Install synchronization for toggle-state items.
%  SYNC(DST,SRC) prepares two items to communicate state changes
%  made to the SRC item state, by causing corresponding and automatic
%  changes in the DST group state.  This achieves a one-sided
%  synchronization, from SRC to DST.
%
%  Typically, one group of buttons and one group of menus are
%  fully synchronized, requiring a call to the sync method on
%  both from "both directions" on the src and dst objects, e.g.,
%       sync(hMenuGroup,hButtonGroup);
%       sync(hButtonGroup,hMenuGroup);
%
%  In this example, the two groups must contain an identical number of
%  items; no child groups or other hierarchy can be contained.  Items in
%  both SRC and DST groups must support a state property as defined by
%  the property StateName; the property name can differ between the
%  groups.  The ordering is 1:1 and in-order, such that a
%  selection change to the first item of the SRC group is reflected
%  in the first item of the DST group, and so on.
%
%  SYNC(DST,SRC,SRCPERM) specifies a permutation vector that allows
%  incomplete or out-of-order 1:1 mappings to be achieved.  SRCPERM
%  is a vector of 1-based indices specifying the items in SRC that are
%  to be related to the sequential elements in DST.  Elements of DST
%  are taken in (creation) order and without skipping; only elements
%  of SRC are subject to the permutation.  Conceptually, each item of
%  DST(1:numel(SRCPERM)) are synchronized to changes in made to the
%  items in SRC(SRCPERM).  Indices refer to creation-order of items
%  in SRC and DST, not render-placement order.
%
%  Not all items in SRC need to be listed in SRCPERM, and not all items
%  in DST need to be addressed.  Items not addressed do not participate
%  in synchronization.
%
%  SYNC(DST,SRC,@MAP) specifies a handle to a mapping
%  function MAP that computes a mapping from SRC to DST items.  It is the
%  responsibility of the MAP function to update widget states
%  appropriately, and can be used to achieve many-to-1 and other mappings.
%  MAP is called with the syntax
%      MAP(dst,dstIdx,src,srcIdx,eventStruct)
%  Note that MAP is called immediately upon sync listener installation
%  to initialize states; this call is identified by eventStruct containing
%  an empty .NewValue property.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/08/14 04:07:31 $

% What this sync operation does:
% - Adds new destination to source sync install list
% - sync list contents are installed during uigroup::renderPost() operation

error(nargchk(2,3,nargin, 'struct'));

% If no 3rd arg, assume the default permutation (no perm)
if nargin<3, arg=[]; end

% Parse arg for either a srcPerm vector or a mapFcn handle
useMapFcn = isa(arg,'function_handle');
if useMapFcn
    mapFcn=arg;
    srcPerm=[];
else
    mapFcn=[];
    srcPerm=arg;
end

% Determine number of elements to synchronize
% We do this slightly differently depending on whether a
% custom mapping fcn is specified.
%
% If a mapping fcn is specified,
%    we simply take the number of source children and
%    iterate over them all.  If there's just one dest child,
%    things work fine.  If there's multiple dest children,
%    an error will result if #src_children > #dst_children
%
% If no mapping fcn is specified,
%    we're using the built-in sync functions, and for
%    these, we take the minimum of min(src) and min(dst)
%    and synchronize just those elements.
%
if ~src.isGroup;
    % Treat source as a single item
    srcChildList{1} = src;
else
    % Source is a uigroup (0 or more items)
    % Build flat list of src children
    srcChild = src.down; % get first src child
    srcChildList = cell(0);
    while ~isempty(srcChild)
        % Record child in list
        srcChildList{end+1} = srcChild; %#ok
        srcChild = srcChild.right; % next src child
    end
end
% Could be a single item, could be a group
Nsrc = numel(srcChildList);

% Get mapping permutation
if ~isempty(srcPerm)
    % Permute list of source child objects
    srcChildList = srcChildList(srcPerm);
else
    % Default permutation: maintain order of src children
    srcPerm = 1:Nsrc;
end

% No permutation on dst
% Note: we must determine if the dst is a group, so we
%   know to look at the children.  But that's not sufficient -
%   if it's a group, we need to know if it has its own WidgetFcn.
%   If so, we treat it as a simple item - the user intends to
%   synchronize (some aspect of) this widget to the src.
% No WidgetFcn?  Great - we grab the children and go.
%
dstIsItem = ~dst.isGroup || dst.TreatAsItemForSyncDst; % ~isempty(dst.WidgetFcn);
if dstIsItem
    Ndst = 1;
    dstChild = dst;  % take this as a simple item
else
    % Treat this as a group of children
    Ndst = getNumChildren(dst);
    dstChild = dst.down; % get first dst child
end
dstPath = getPath(dst);  % text path to dstChild

if useMapFcn && (Ndst==1)
    % We sync ALL source objects to ONE dest object
    % if a map fcn is utilized.  It's a convenient
    % special case used for many-to-1 sync's.
    % But if there are, say, 3 src items and 2 dst items,
    % we clip to 2 total and go from there (i.e., use
    % the "min()" computation)
    Nsync = Nsrc;
else
    % It is the minimum of src and dst elements
    % E.g., if there are 3 src items and 4 dst items,
    % sync only 3 items.
    Nsync = min(Nsrc,Ndst);
end

% Add sync list items to src object
%
for i = 1:Nsync
    % It is assumed that the children here are uiitem's
    % and that we are called during renderPost,
    % so the uiitem children are rendered widgets,
    % each supporting the property defined in cProp
    
    % already have dstChild set
    % get next (permuted) src child
    srcChild = srcChildList(i);
    
    % Specify sync function and args
    if useMapFcn
        % User-supplied mapping fcn
        %
        % Special args: (dst,iDst, src,iSrc,ev)
        % NOTE: for initial-sync, ev=[]
        %       for non-initial-sync, ev=0 (i.e., non-empty)
        %
        % syncFcn = @(hh,ev)mapFcn(dst,i,src,srcPerm(i),ev);
        fcnRaw = mapFcn;
        argsRaw = {dst,i,src,srcPerm(i)};
    else
        % Do NOT encode dstWidget directly into the listener callback
        % It will fail under the conditions noted above
        %
        % Default args: (dstChild,ev)
        % NOTE: for initial-sync call, we set ev.NewValue=[]
        %                              and ev.Source.Name=''
        %       for non-initial-sync, ev.NewValue='on' or 'off'
        %
        % syncFcn = @(hh,ev)SimpleWidgetSync(dstChild,ev);
        fcnRaw = @SimpleWidgetSync;
        argsRaw = {dstChild};
    end
    
    % SyncList uses lazy instantiation
    % We may need to instantiate a synclist object here,
    % before continuing on with the "add" operation
    if isempty(srcChild{1}.SyncList)
        srcChild{1}.SyncList = uimgr.uisynclist;
        % Add new destination to source sync install list
        % This is installed during uigroup render operation
        %   (this is the key step of the sync method!)
    end
    add(srcChild{1}.SyncList, fcnRaw,argsRaw, ~useMapFcn, dstPath);
    % Get next dst item (sequential, not permuted) if dst has children
    % that we are traversing (otherwise, stay with the same dst item)
    if ~dstIsItem && (i<Nsync)
        % no need to execute this code on last iteration
        %
        % in fact, it will cause getPath to fail since
        % dstChild will be empty in that iteration.
        dstChild = dstChild.right;
        dstPath = getPath(dstChild);
    end
end

end % installItemSync

% ----------------------------------
function SimpleWidgetSync(dstChild,ev)
%SimpleWidgetSync

% This can fire even when dst does not have a rendered widget
% (why? src widget is present and has listeners ... but that
%  says nothing about whether dst has a widget at this time)
%
% This just means dst widget handle could be empty or invalid,
% so we must check that before proceeding

% ev.NewValue is the new value of the property that changed
if isa(ev, 'event.PropertyEvent')
    srcValue = ev.AffectedObject.(ev.Source.Name);
else
    srcValue = ev.NewValue;
end

if ~isempty(srcValue)
    
    hWidget = dstChild.hWidget;
    isWidgetHandle = uimgr.isHandle(hWidget);
    if isWidgetHandle
        % Sync from src to dst
        % Properties that can change
        %	Visible, Enable, (StateName)
        srcProp = ev.Source.Name;
        if any(strcmpi(srcProp,{'visible','enable'}))
            % Enable and Visible propagate to the parent (uimgr) item
            dstChild.(srcProp)=srcValue;
        else
            % all others properties (that would be just stateProp)
            % propagate to the child (hg) widget.
            % It is presumed that the value for the src property
            % makes sense as the value of the dst property
            % (here, 'checked','state',etc, are all on/off properties,
            %  and so we think we're on safe ground)
            set(hWidget, dstChild.StateName, srcValue);
        end
    end
end

end % SimpleWidgetSync

% [EOF]

function add(h,varargin)
%ADD Add one or more children to group.
%   H.ADD(C1,C2,...) adds one or more children C1, C2, ..., to the group.
%   H.ADD('Name',C1,C2,...) adds one or more children to named child of
%   group.  If named child does not exist, an error is thrown.  If the
%   named child is not a group itself, an error is thrown.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:34 $

if (nargin>1) && ischar(varargin{1})
    % Add children to named group
    childName = varargin{1};
    hChild = h.findchild(childName);
    if isempty(hChild)
        % This is an error by the caller:
        error('uimgr:ChildNotFound', 'Child "%s" not found.', childName);
    end
    % Invoke add method on named group
    hChild.add(varargin{2:end});
else
    % Add to end of group at the "top level"
    % There can be multiple new children to add
    
    parentClass = class(h);
    
    for i = 1:numel(varargin)
        theChild = varargin{i};
        
        % Check for unique name
        if isDuplicateName(h,theChild)
            error('uimgr:uigroup:DuplicateChildName', ...
                'Cannot add child to group; duplicate name "%s" specified.',theChild.Name);
        end
        % Check for parent/child compatibility
        if ~compatibleParent(theChild, parentClass)
            error('uimgr:uigroup:IncompatibleChild', ...
                'Cannot add incompatible child "%s" of class "%s" to parent "%s" of class "%s"', ...
                theChild.Name, class(theChild), h.Name, parentClass);
        end
        
        % Change placement of child if AutoPlacement is set
        % We only do this when adding children to a group.
        % Placement is set to (highest placement value)+1.
        % This sets auto-children to distinct placements, allowing
        % new plug-in's to set placements between children when
        % needed.  Explicit placements may always be specified
        % by caller, in which case that value is taken.
        if theChild.AutoPlacement
            theChild.ActualPlacement = getDefaultPlacement(h);
        end
        
        % Add child to parent
        connect(h,theChild,'down');

        % Take any post-add actions necessary for the parent
        % We also send the child index in case it is needed
        % (index of storage, not of placement/display)
        addPost(h, theChild, i);
    end
end

% [EOF]

function unrenderedCode = incrUnrender(h)
%INCRUNRENDER Incremental unrender subtree.
%   Unrender nodes selectively (minimally) based on the
%   render-state of older siblings.
%
%   unrenderedCode: 0=all nodes are already rendered
%                   1=local widget is unrendered
%                  >1=grandchild is unrendered

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/04/27 19:55:09 $

%   Find all isUnrendered() nodes
%      has a local widget?  if unrendered, we unrender right siblings
%      no local?  has children, likely, and this is a group
%         so here, if any children are unrendered, we still
%         must invalidate right children
%   Unrender all right-siblings (sorted-placement order)

unrenderedCode = 0;  % assume all nodes rendered

if isUnrendered(h)  % considers local widgetfcn only
    % This item or group is (at least partially) unrendered
    % Do a full unrender on it
    
    % this call is most likely unnecessary - and somewhat expensive
    %
    % only worrying about children that may be rendered,
    % while the local group widget is NOT rendered
    % How exactly did this happen?
    % If the parent widget is not rendered, graphical children
    % are deleted (think of parent menus with child menu entries)
    %
    % Note: statusbar may have this issue, perhaps, but unclear
    %
    % unrender(h,true);
    unrenderedCode = 1;  % local widget found to be unrendered
    
elseif h.isGroup
    % Descend to update children
    % Defer rendering to the nearest parent node with a widget
    
    childObjOrder = computeChildOrder(h,true,inf);
    N = numel(childObjOrder);
    allchild_unrenderedCodes = zeros(1,N);
    
    for i=1:N
        % Visit all children, whether we're a widget-node or not
        % (incrUnrender() could unrender grandchildren somewhere)
        hChild = childObjOrder{i};
        
        % unrenderedCode could signify that the child itself,
        % or a grandchild, is unrendered
        child_unrenderedCode = incrUnrender(hChild);
        
        % determine if THIS child is a nonwidget group
        % ... but we need to consider product of this for
        %     all grandchildren to know what to do
        childIsNonWidgetGroup = isempty(hChild.WidgetFcn);
        
        % if this entry (one of the children of the group) is unrendered,
        %   then we must think about unrendering all younger siblings
        %
        % We unrender younger siblings if this child is an unrendered ITEM
        %   (i.e., not a group), since items render their widget in the
        %   stack of sibling widgets and all younger siblings must be
        %   unrendered to permit this. 
        %  (assumes append-only widget rendering, as in buttons and status)
        %
        % We also unrender younger siblings if this child is an unrendered
        %   NON-WIDGET GROUP, since that type of group renders its children
        %   similarly (i.e., in the stack of sibling widgets).
        %
        % Ditto again for an unrendered WIDGET GROUP, if the LOCAL widget
        %   itself is unrendered.
        %
        % BUT! In case of an unrendered WIDGET GROUP with a LOCAL widget,
        %   and that LOCAL widget itself IS rendered, then the fact a
        %   CHILD of this group is unrendered.  The child of a LOCAL widget
        %   group does NOT render in the stack of widgets.
        %   We do not unrender the PARENT in this case, so we take
        %   case to signal this in the recursive call.
        % 
        affects_younger_siblings = ...
            (child_unrenderedCode==1) || ...
            ((child_unrenderedCode>1) && childIsNonWidgetGroup);
        
        % Return code that this child is unrendered
        % actual # represents how deep the unrendered child was found
        %   -> 1=parent node, 2=immediate child
        %
        % if this unrendering does NOT influence the parent,
        % override this code with 0
        if ~affects_younger_siblings
            child_unrenderedCode = 0;
        end
        allchild_unrenderedCodes(i) = child_unrenderedCode;
        
        % unrender all younger siblings
        if affects_younger_siblings
            % younger sibling == located "right" or "down",
            %     in sorted placement order
            for j=i+1:N
                % true: suppress side-effect work (separator updates)
                % since a subsequent render() call will do that for us
                %
                % xxx note that unrender() calls isRendered(), which
                % is expensive and redundant - we already know we
                % must be rendered.  No cure offered at present...
                hSib = childObjOrder{j};
                %fprintf('unrendering "%s"\n',getPath(hSib));
                unrender(hSib,true);
            end
            % NOTE! Early termination of i-loop here, to stop
            %       checking siblings since we've unrendered them
            break
        end
    end  % child (i) loop
    
    % If all children were rendered, return 0 (default set above)
    % Otherwise, return "shallowest child" (lowest number) code
    if any(allchild_unrenderedCodes > 0)
        parentIsNonWidgetGroup = ~isa(h.WidgetFcn,'function_handle');
        % parentIsNonWidgetGroup = isempty(h.WidgetFcn); % See g374132
        if parentIsNonWidgetGroup
            % For non-widget parent, treat any child changes
            % as if they were changes in the parent itself
            unrenderedCode = 1;
        else
            unrenderedCode = 2;
        end
    end
end

% [EOF]

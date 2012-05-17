function unrender_widget(h, suppressSeparatorUpdate)
%UNRENDER_WIDGET Unrender graphical rendering of item.
%  "Protected" method callable by both
%     uigroup::unrender()
%  and by
%     uiitem::unrender()
%
%  This does not destroy the uiitem object;
%  it only removes the underlying graphical rendering.
%  The object may be re-rendered at a later time.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/07/23 18:44:24 $

% NOTE:
%  A point of possible confusion for the unsuspecting:
%  For a uiitem, the child is an HG widget of some type.
%  These objects support a "delete" method that "destroys" the object
%  To unrender the HG child, we must delete it.  We would call it
%  remove or destroy, if we had our way.
%
%  For a uigroup, the children are either uiitems or uigroups
%  The delete method unrenders those children by calling delete.

theWidget = h.hWidget;
isWidgetHandle = uimgr.isHandle(theWidget);
if isWidgetHandle
    % Check that hWidget is a valid handle, and not, say,
    % a deleted widget handle.  (Note that if hWidget=[],
    % ishandle() returns empty, and the body of the if
    % does not execute.)
    %
    % hWidget holds the "rendered" HG uibutton, not the
    % function that renders the button
    
    % Cache properties needed to restore widget state
    % See render_widget or schema for details
    %
    fillRenderCache(h);        % sets h.RenderCache
    fillCustomRenderCache(h);  % sets h.CustomRenderCache
    
    % Delete widget, destroy allocation/handle
    if isjava(theWidget)
        % Get toolbar parent
        theWidget = javacomponent(theWidget);
    end
    
    delete(theWidget);
    h.hWidget = [];
    
    % Item is now unrendered
    %
    % If the suppressSeparatorUpdate flag is not passed,
    % this is a "localized" unrender on a single uiitem.
    % Hence the need to "report in" to the parent and update separators.
    % We could have done this using a listener, but it is inefficient
    % to create listeners during construction time.
    %
    % If flag not passed, assume FALSE (i.e., don't suppress event)
    if (nargin<2) || ~suppressSeparatorUpdate
        hParent = h.up;
        if ~isempty(hParent)
            % flags: don't descend, don't disregard visibility
            enforceItemSeparators(hParent,true,false);
        end
    end
else
    % Bogus handle was stored
    % Widget must have been destroyed through some means
    % other than the unrender call
    h.hWidget = [];
end

% [EOF]

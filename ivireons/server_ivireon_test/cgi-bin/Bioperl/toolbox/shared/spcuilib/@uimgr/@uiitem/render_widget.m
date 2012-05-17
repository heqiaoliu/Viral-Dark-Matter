function render_widget(h)
%RENDER_WIDGET Render an item.
%  "Protected" method callable by both
%     uigroup::render()
%  and by
%     uiitem::render()
%
%   This adds the equivalent of an HG child to the item.
%   Keep in mind, this renders a SINGLE ITEM, even if the
%   node is a group.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/08/14 04:07:29 $

% No point trying to render a widget if one doesn't exist!
% Also, the isRendered call can be slow if this is a uigroup
% that never has its own widget -- isRendered descends to find
% the first rendered child.  So performance suggests testing
% the WidgetFcn first.
%
% We don't need the whole isRendered() call, either.
% We simply need to know if this local widget is rendered yet.
%
% Finally, we keep a temporary copy of h.WidgetFcn outside the
% "isempty()" test.  The body of this if-statement is not
% jit'ing, and the isempty() test is remarkably slower if jit is not
% being used AND there is a struct-access in the argument.  Splitting
% it improves performance.
%
WidgetFcn = h.WidgetFcn;
if ~isempty(WidgetFcn)
    % Need to keep this as a call to isRendered, and not
    % a (cheaper/faster) call to isempty(h.hWidget).  Why?
    % isRendered() is overloaded for uistatus, which smartly
    % determines if the (high-level uistatus) object is rendered.
    %
    if ~isRendered(h)
        % A potentially cheaper way to test "~isRendered(h)",
        % but uistatus is not happy with that
        % 	theWidget = h.hWidget;
        % 	if isempty(theWidget) || ~ishandle(theWidget)
        
        % If item child (which is the HG widget) has already
        % been rendered, don't re-render
        %
        % Instantiate child by executing fcn-handle
        % We pass one argument, the parent handle:
        
        % Render child widget by evaluating user function
        theWidget = WidgetFcn(h);
        h.hWidget = theWidget;
        
        % WidgetProperties:
        % User-specified list of properties and values to use when
        % rendering a widget.  Defaults to empty.
        %
        % RenderCache:
        % Setup managed properties after widget was rendered
        % via the user-function above
        %
        % First, get cell-vector of param/value pairs from
        % cache recorded at last unrender.  Or, from cache
        % setup by an advanced user prior to first render call.
        %
        % This method is overloaded on a ui-class basis.
        % So uibutton's can have different cached properties
        % as compared to uimenu's or uistatusbars.  Cache is
        % filled in unrender_widget, or by a caller prior to
        % first render.
        %
        % CustomRenderCache:
        % Allow user-specific overrides to param caching.
        % This is used in situations where the "Default" property
        % caching isn't retaining a property that the user was
        % overriding with the application for a certain widget.
        %
        % We don't want to cache all possible properties by default,
        % as it would make unrender/render cycles prohibitively slow.
        % So user may need to add specific properties as needed.
        %
        % Cache is created in unrender_widget, and derives from
        % the h.CustomPropertyCacheList.
        %
        pv_pairs = [h.WidgetProperties h.RenderCache h.CustomRenderCache];
        
        % Add to pv-pair list those properties set locally on widget
        % Get these property values from the uiitem,
        %   and push them down onto the widget
        params = {'Visible','Enable','Separator'};
        for i=1:numel(params)
            p_i = params{i};
            if isprop(theWidget,p_i) || (isobject(theWidget) && ~isempty(findprop(theWidget,p_i)))
                pv_pairs = [pv_pairs {p_i, h.(p_i)}]; %#ok
            end
        end
        
        % Set all property/value pairs
        if ~isempty(pv_pairs)
            set(theWidget, pv_pairs{:});
        end
        
        % Install listeners on widget to achieve item synchronization
        % (if any synclist items are registered)
        if ~isempty(h.SyncList) % not instantiated = no sync list!
            installSyncListeners(h.SyncList, h);
        end
    end
end

% [EOF]

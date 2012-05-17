function resetView(h)

%   Copyright 2009 The MathWorks, Inc.

% reset the current view to its factory settings w/o side effects
if ~isempty(h.getActiveView)        
    % If this is our factory view.
    if ~isempty(h.ActiveView.InternalName)
        % insert the new view where the old view was        
        oldView = h.ActiveView;
        internalName = h.ActiveView.InternalName;
        viewName = regexp(internalName, '_', 'split');
        viewName = char(viewName(2));    
        newView = h.getFactoryViews(viewName);
        if ~isempty(newView)
            h.disableLiveliness;
            position = 'left';
            viewPosition = [];            
            if ishandle(oldView.left)
                viewPosition = oldView.left;                
            elseif ishandle(oldView.right)
                viewPosition = oldView.right;
                position = 'right';
            end
            oldView.delete;
            h.addView(newView);
            if ~isempty(viewPosition) && ishandle(viewPosition)
               newView.connect(viewPosition, position);            
            end
            h.enableLiveliness;
            h.ActiveView = newView;
        end
    end
end
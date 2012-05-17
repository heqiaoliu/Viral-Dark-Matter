function y = isUnrendered(h)
%isUnrendered True if WidgetFcn not rendered.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/08/14 04:07:34 $

if ~isa(h.WidgetFcn,'function_handle')
% if isempty(h.WidgetFcn) % See g374132 
    % By definition, if we're an item with no widgetFcn,
    % we can't have anything to render.  Being "unrendered"
    % means we have something that needs to be rendered.
    % So we must answer FALSE.
    
    y = false;
else
    hWidget = h.hWidget;
    if isempty(hWidget)
        y = true;
    else
        if isjava(hWidget)
            y = ~isValid(hWidget);  % a Java method
        else
            amiHGHandleObject = ishghandle(hWidget);
            if (amiHGHandleObject)
                y = ~amiHGHandleObject;
            else
                y = ~ishandle(hWidget) && ~isobject(hWidget);
            end      
        end
    end
end

% [EOF]

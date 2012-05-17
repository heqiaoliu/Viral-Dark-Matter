function y = isRendered(h)
%isRendered Return true if item has a rendered widget.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/08/14 04:07:28 $

hWidget = h.hWidget;
if isjava(hWidget)
    y = isValid(hWidget);  % a Java method
else
    isWidgetHandle = uimgr.isHandle(hWidget);
    
    y = ~isempty(hWidget) && (isWidgetHandle || isa(hWidget, 'spcwidgets.AbstractWidget'));
end

% [EOF]

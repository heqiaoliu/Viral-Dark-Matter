function y = isRendered(h)
%isRendered Return true if group is rendered.
%   Definition: is THIS widget rendered?
%   If the group node has no WidgetFcn,
%        then it does not support a widget itself
%        thus the answer to "isRendered" must be answered by
%        examining the group's children
%   If the group node has a WidgetFcn,
%        the answer is simply whether the group widget is rendered

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/08/14 04:07:26 $

if ~isempty(h.hWidget)
    y = uimgr.isHandle(h.hWidget) || isa(h.hWidget, 'spcwidgets.AbstractWidget');
else
    % If any child is rendered, the answer is true
    y = false;
    h = h.down;  % get child
    while ~isempty(h)
        y = isRendered(h);
        if y, return; end
        h = h.right;  % next child
    end
end

% [EOF]

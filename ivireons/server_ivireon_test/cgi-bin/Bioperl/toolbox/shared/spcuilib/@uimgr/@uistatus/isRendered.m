function y = isRendered(h)
%isRendered Return true if uistatus is rendered.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:33 $

hWidget = h.hWidget;
y = ~isempty(hWidget) && (hWidget.Index>0);
% [EOF]

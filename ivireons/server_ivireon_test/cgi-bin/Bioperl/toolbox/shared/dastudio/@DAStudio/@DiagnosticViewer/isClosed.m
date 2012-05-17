function b = isClosed(h)
%  isClosed
%
%  Returns true if the Diagnostic Viewer window is hidden.
%
%  Copyright 2008 The MathWorks, Inc.

    b = ~h.isVisible();

end
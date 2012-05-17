function cleanupLine(this, hVisParent)
%CLEANUPLINE Cleanup the line components.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/27 19:55:25 $

cleanupAxes(this, hVisParent)

if ishghandle(this.AxesContextMenu)
    delete(this.AxesContextMenu);
end

if ishghandle(this.LineContextMenu)
    delete(this.LineContextMenu);
end

% [EOF]

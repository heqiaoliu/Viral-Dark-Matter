function cleanupAxes(this, hVisParent)
%CLEANUPAXES Cleanup the axes.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:59:17 $

if ishghandle(this.Axes)
    delete(this.Axes);
end

% Give up control of the resize fcn for the visualization uicontainer.
set(hVisParent, 'ResizeFcn', []);

% [EOF]

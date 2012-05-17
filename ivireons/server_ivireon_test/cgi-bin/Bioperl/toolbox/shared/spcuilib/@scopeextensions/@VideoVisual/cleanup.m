function cleanup(this, hVisParent)
%CLEANUP Clean up the visual's HG components

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:58:42 $

cleanupAxes(this, hVisParent);

% Make sure that the scroll panel is deleted.  Deleting the axes will not
% delete it.  Deleting the scrollpanel will not delete the axes.
if ishghandle(this.ScrollPanel)
    delete(this.ScrollPanel);
end

% [EOF]

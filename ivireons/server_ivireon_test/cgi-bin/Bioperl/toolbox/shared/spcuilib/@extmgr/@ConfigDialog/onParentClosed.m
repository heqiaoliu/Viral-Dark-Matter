function onParentClosed(this)
%ONPARENTCLOSED 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:49:10 $

% Close dialog if it exists
if isempty(this.Dialog),
    cleanupSubdialogs(this);
else
    delete(this.Dialog);
end


% [EOF]
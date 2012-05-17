function hTop = getRoot(h)
%GETROOT Return root node in UIMgr tree.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:40:34 $

% By definition, h cannot be empty to start
% otherwise we would not dispatch to this method
% So we do not need to preset hTop=h

while ~isempty(h), hTop=h; h=h.up; end

% [EOF]

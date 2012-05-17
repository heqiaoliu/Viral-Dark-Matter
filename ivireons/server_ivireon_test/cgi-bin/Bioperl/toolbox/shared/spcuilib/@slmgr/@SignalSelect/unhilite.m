function unhilite(this)
%UNHILITE  Turn off highlighting for the connection and driver block

% Copyright 2005 The MathWorks, Inc.

% If there is no valid line, nothing to un-highlight
% (no need to check blkh -- if lineh is valid, so is blkh)
% Set new hilite state
for indx = 1:numel(this)
    hilite(this(indx).Line,'off');
    hilite(this(indx).Block,'off');
end

% [EOF]

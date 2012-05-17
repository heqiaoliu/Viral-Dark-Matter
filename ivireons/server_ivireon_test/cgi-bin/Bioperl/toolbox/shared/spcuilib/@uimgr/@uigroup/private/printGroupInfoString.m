function printGroupInfoString(ch,level,i)
%printGroupInfoString Display group info to the command window.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:31:03 $

s = sprintf('%sChild %d: %s', ...
    blanks(3*level), i, getGroupInfoString(ch));
disp(s);

% [EOF]

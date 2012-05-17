function varargout = explore
%EXPLORE  Explore the library database.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/04/09 19:04:41 $

h = extmgr.Explorer;
h.show;

if nargout
    varargout = {h};
end

% [EOF]

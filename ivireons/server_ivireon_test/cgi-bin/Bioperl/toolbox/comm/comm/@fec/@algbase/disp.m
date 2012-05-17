function disp(h)
%DISP  Object display.
%  DISP(H) displays all object properties.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:03 $

% If h is a vector use the built-in display method
if isscalar(h)
    get(h);
else
    builtin('disp', h);
end


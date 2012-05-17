function flag = isColonIndex(s)
%Check if s is a colon index.

% Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:14:42 $

flag = isequal(s,':') && ischar(s);

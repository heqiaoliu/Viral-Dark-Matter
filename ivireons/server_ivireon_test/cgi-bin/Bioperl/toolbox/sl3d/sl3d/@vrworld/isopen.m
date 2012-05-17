function x = isopen(w)
%ISOPEN True for an open VRWORLD object.
%   ISOPEN(W) returns an array that contains 1's where the elements
%   of W are open VRWORLD objects and 0's where they are either closed
%   or invalid.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:11:04 $ $Author: batserve $


x = false(size(w));
for i = 1:numel(w);
  x(i) = isvalid(w(i)) && strcmpi(get(w(i), 'Open'), 'on');
end

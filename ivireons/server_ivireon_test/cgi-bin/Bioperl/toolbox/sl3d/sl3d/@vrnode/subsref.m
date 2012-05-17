function y = subsref(x, s)
%SUBSREF  Subscripted reference for VRNODE objects.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:44 $ $Author: batserve $


% '.' overloads to 'getfield', everything else left alone
switch s(1).type
  case '.'
    y = getfield(x, s(1).subs);   %#ok this is overloaded GETFIELD
  otherwise
    y = builtin('subsref', x, s(1));
end

% if this is not the last level of subsref, do the rest
if length(s)>1
  y = subsref(y, s(2:end));
end

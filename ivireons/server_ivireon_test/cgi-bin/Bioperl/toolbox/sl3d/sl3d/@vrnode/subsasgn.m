function x = subsasgn(x, s, v)
%SUBSASGN  Subscripted assignment for VRNODE objects.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:43 $ $Author: batserve $


% '.' overloads to 'setfield', everything else left to subsref'ed objects
switch s(1).type
  case '.'
    setfield(x, s(1).subs, v);   %#ok this is overloaded SETFIELD
  otherwise
    subsasgn(subsref(x, s(1)), s(2:end), v);
end

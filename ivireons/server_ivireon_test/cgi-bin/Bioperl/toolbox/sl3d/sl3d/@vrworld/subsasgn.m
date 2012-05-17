function x = subsasgn(x, s, v)
%SUBSASGN  Subscripted assignment for VRWORLD objects.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:11:12 $ $Author: batserve $


% leave it to subsref'ed objects
subsasgn(subsref(x, s(1)), s(2:end), v);

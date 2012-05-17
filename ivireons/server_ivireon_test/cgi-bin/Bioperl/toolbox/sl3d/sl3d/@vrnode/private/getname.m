function name = getname(name)
%GETNAME Get the NAME which is always valid VRML node name.
%   NAME = GETNAME(NAME) gets the NAME which is always valid VRML identifier
%   of the current VRNODE object. Resulting NAME is empty if the current VRNODE object is unnamed.
%
%   Private function.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/10/16 06:45:31 $ $Author: batserve $

if ~isempty(name) && name(1) == '#'
  name = '';
end

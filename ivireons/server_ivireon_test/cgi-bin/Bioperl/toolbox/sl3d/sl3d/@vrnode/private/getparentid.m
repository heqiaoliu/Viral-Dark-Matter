function x = getparentid(n)
%GETPARENTID Get the ID of the parent VRWORLD object.
%   X = GETPARENTID(N) gets the ID of the parent VRWORLD object.
%
%   Private function.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:47 $ $Author: batserve $

sw = struct(n.World);
x = [sw.id];

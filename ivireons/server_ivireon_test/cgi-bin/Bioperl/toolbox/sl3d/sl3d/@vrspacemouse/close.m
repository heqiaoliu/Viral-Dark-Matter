function close(mouse)
%CLOSE Close the Space Mouse object.
%   CLOSE(MOUSE) closes and invalidates the Space Mouse object. The
%   object cannot be used after it is closed.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:50 $ $Author: batserve $

spacemouse('MLClose', getAll(mouse));

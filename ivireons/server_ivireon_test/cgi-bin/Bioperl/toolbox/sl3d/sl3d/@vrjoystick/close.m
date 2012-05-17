function close(joy)
%CLOSE Close a joystick object.
%   CLOSE(JOY) closes and invalidates the joystick object. The
%   object cannot be used after it is closed.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:27 $ $Author: batserve $

joyinput('MLClose', joy);

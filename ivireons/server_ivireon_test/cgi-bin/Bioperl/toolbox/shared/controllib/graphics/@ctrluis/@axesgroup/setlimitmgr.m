function setlimitmgr(h,eventdata)
%SETLIMITMGR  Enables/disables limit manager.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:38 $
% Postset for LimitManager property: enable/disable listeners managing limits

h.LimitListeners.setEnabled(strcmpi(h.LimitManager,'on'))

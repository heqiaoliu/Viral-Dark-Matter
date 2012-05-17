function enable_listener(hMgr, eventData)
%ENABLE_LISTENER Listener to the Enable Property.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:17:14 $

siggui_enable_listener(hMgr);
if strcmpi(hMgr.Enable,'on'), stack_listener(hMgr); end

% [EOF]

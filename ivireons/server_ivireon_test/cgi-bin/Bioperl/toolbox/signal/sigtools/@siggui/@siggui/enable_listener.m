function enable_listener(hObj, varargin)
%ENABLE_LISTENER The listener for the enable property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/13 00:25:50 $

% WARNING: This is the superclass listener which will perform a "blind"
% enable or disable.  If you want to only disable/enable certain UIControls
% you must overload this method.  It is recommended that you always disable
% all UIcontrols when the object is disabled.

siggui_enable_listener(hObj, varargin{:});

% [EOF]

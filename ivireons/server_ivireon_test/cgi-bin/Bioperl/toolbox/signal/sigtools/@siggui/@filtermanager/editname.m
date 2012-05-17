function editname(this)
%EDITNAME   Programmatically give focus to the name editbox.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:13 $

uicontrol(getappdata(this.Handles.popup, 'EditBox'));

% [EOF]

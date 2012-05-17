function cbs = callbacks(hXP)
%CALLBACKS Callbacks for the Export Dialog

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:33 $

cbs.popup    = @popup_cb; 

% --------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, hXP)

set(hXP, 'CurrentDestination', popupstr(hcbo));

% [EOF]

function cbs = callbacks(h)
%CALLBACKS Callbacks for the EXPORT2HARDWARE dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:07:45 $

cbs.popup = @popup_cb;
cbs.check = @check_cb;


% ------------------------------------------------------------
function popup_cb(hcbo, eventStruct, h)

set(h, 'ExportMode', popupstr(hcbo));


% ------------------------------------------------------------
function check_cb(hcbo, eventStruct, h)

set(h, 'DisableWarnings', get(hcbo, 'Value'));

% [EOF]

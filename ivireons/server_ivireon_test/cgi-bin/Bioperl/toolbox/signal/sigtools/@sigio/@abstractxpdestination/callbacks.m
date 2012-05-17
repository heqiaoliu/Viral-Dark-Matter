function cbs = callbacks(h)
%CALLBACKS Callbacks for the Export Dialog

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:13 $

cbs.exportas = @exportas_cb;
cbs.checkbox = @checkbox_cb;


% --------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, h)

set(h, 'ExportAs', popupstr(hcbo));


% --------------------------------------------------------------------
function checkbox_cb(hcbo, eventStruct, h)

set(h, 'Overwrite', get(hcbo, 'Value'));

% [EOF]

function cbs = callbacks(hConvert)
%CALLBACKS Callbacks for the HG objects in the Convert Dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:20:17 $

cbs.listbox = @listbox_cb;


% -----------------------------------------------------------
function listbox_cb(hcbo, eventStruct, hConvert)

index  = get(hcbo,'Value');
string = get(hcbo,'String');

set(hConvert,'TargetStructure',string{index});

% [EOF]

function cbs = callbacks(hSOS)
%CALLBACKS Callbacks for the SOS Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:33:24 $ 

cbs.scale     = @scale_cb;
cbs.direction = @direction_cb;

% ---------------------------------------------------------------------
function scale_cb(hcbo, eventStruct, hSOS)

val = popupstr(hcbo);

set(hSOS,'Scale',val);


% ---------------------------------------------------------------------
function direction_cb(hcbo, eventStruct, hSOS)

val = popupstr(hcbo);

set(hSOS,'Direction',val);

% [EOF]

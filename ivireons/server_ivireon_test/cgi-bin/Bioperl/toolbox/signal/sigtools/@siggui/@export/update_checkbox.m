function update_checkbox(hXP)
%UPDATE_CHECKBOX Update the Overwrite checkbox

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:22:43 $

h = get(hXP,'Handles');

% Sync the checkbox with the overwrite flag
overWrite = get(hXP,'Overwrite');
set(h.checkbox,'Value',overWrite);

% [EOF]

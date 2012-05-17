function visible_listener(hCoeff, eventData)
%VISIBLE_LISTENER Overload Superclass method

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:19:16 $

siggui_visible_listener(hCoeff);
update_labels(hCoeff);

% [EOF]

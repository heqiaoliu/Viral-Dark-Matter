function figure_listener(h, eventData)
%FIGURE_LISTENER Listener for the deletion of the figure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:33:00 $

if isa(h, 'siggui.siggui'),
    unrender(h);
end

% [EOF]

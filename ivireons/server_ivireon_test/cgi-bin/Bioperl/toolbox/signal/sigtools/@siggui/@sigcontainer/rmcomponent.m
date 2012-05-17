function rmcomponent(this, h)
%RMCOMPONENT   Remove the component.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:19:32 $

error(nargchk(2,2,nargin,'struct'));

h = h(:)';

for hindx = h
    if ~isa(hindx, 'siggui.siggui'),
        warning('Signal:sigcontainer:ChildMustBeSiggui', 'Children must inherit from SIGGUI.');
    else
        disconnect(hindx);
    end
end

% Call a separate method to add the listener to the notification event.
% This will allow subclasses to overload this method.
attachnotificationlistener(this);

% [EOF]

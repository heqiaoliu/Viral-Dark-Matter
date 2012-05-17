function cancel(h)
%CANCEL Undo the current operation

%   Author(s): D. Foti & J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:39:47 $

% Loop to allow for the cancel of multiple transactions.
for i = 1:length(h)

    set(h(i).PropertyListeners, 'Enabled', 'off');
    
    % Undo the operation
    h(i).undo;
end

% [EOF]

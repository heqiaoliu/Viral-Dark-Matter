function cancel(this)
%CANCEL Perform the cancel action of the Parameter Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:24:45 $

if isrendered(this),
    set(this, 'Visible', 'Off');
    
    dp = get(this, 'DisabledParameters');
    
    % Redraw the controls
    parameters_listener(this);
    set(this, 'DisabledParameters', dp);
end

% Reset the parameters.
hPrm = get(this, 'Parameters');
for indx = 1:length(hPrm)
    send(hPrm(1), 'UserModified', sigdatatypes.sigeventdata(hPrm(1), ...
    'UserModified', get(hPrm(1), 'Value')));
end

% [EOF]

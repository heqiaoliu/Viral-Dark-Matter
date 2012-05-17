function hManag = winmanagement
%WINMANAGEMENT Constructor for the winmanagement object.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:33:46 $


% Instantiate the object
hManag = siggui.winmanagement;

% Set up the default
set(hManag, 'Nbwin', 0);
set(hManag, 'Version', 1);

% Install listeners
installListeners(hManag);


%---------------------------------------------------------------------
function installListeners(hManag)

% Create the listeners
listener(1) = handle.listener(hManag, hManag.findprop('Selection'), ...
    'PropertyPostSet', @selection_listener);
listener(2) = handle.listener(hManag, hManag.findprop('Currentwin'), ...
    'PropertyPostSet', @currentwin_listener);

% Set hManag to be the input argument to these listeners
set(listener,'CallbackTarget', hManag);

% Save the listeners
% The following listeners need to be fired even if the object is 
% not rendered because they send events
set(hManag,'Listeners', listener);


% [EOF]

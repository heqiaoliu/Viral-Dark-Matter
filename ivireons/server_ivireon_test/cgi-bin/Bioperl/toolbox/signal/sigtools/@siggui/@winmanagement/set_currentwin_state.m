function set_currentwin_state(hManag, state)
%SET_CURRETWIN_STATE Sets the state of the current window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:33:55 $ 

% Gets the handle to the current window
winlist = get(hManag, 'Window_list');
index = get(hManag, 'Currentwin');
currentwin = winlist(index);

% Sets the state of the current window
setstate(currentwin, state);

% Fire listeners
set(hManag, 'Window_list', get(hManag, 'Window_list'));
set(hManag, 'Selection', get(hManag, 'Selection'));
set(hManag, 'Currentwin', index);

% [EOF]

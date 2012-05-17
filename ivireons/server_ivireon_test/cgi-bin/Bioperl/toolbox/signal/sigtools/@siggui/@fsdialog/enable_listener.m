function enable_listener(hFs, eventData)
%ENABLE_LISTENER Listener to the enable property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:25:20 $

% In R13 replace with:
%
% super::enable_listener(hFs, eventData);
% set(hFs.Specifier, 'Enable', hFs.Enable);

% Set the enable state of the buttons and the specifier
enabState = get(hFs,'Enable');
h = get(hFs, 'Handles');
set(convert2vector(h.btns),'Enable',enabState);
set(hFs.Specifier, 'Enable', enabState);

isapplied_listener(hFs, eventData);

% [EOF]

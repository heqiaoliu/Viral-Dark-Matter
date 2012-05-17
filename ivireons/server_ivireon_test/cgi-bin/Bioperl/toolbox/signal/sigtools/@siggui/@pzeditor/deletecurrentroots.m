function deletecurrentroots(hObj)
%DELETECURRENTROOTS Delete the current Roots

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:20 $

% Remove the current roots from the list.
set(hObj, 'Roots', setdiff(get(hObj, 'Roots'), get(hObj, 'CurrentRoots')));

% Set the current roots to [].
set(hObj, 'CurrentRoots', []);

% [EOF]

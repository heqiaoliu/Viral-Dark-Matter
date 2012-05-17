function rmcomponent(hParent, hChild)
%RMCOMPONENT Remove a component

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:58:29 $

hAllChildren = get(hParent, 'SigguiComponents');

set(hParent, 'SigguiComponents', setdiff(hAllChildren, hChild));

% [EOF]

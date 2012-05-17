function h = getkeyhandles(this)
%GETOBJBEINGDESTROYED Returns the handles to the objects which will cause
%an unrender

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:45:42 $

h = get(this, 'Handles');
h = h.axes;

% [EOF]

function current = get_current(this, current)
%GET_CURRENT   PreGet function for the 'current' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:17 $

current = get(this, 'privCurrentFilter');

% [EOF]

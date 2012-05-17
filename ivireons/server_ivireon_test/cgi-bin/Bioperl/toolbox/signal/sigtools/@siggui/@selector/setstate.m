function setstate(h, s)
%SETSTATE Set the state of the selector object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2006/10/18 03:28:58 $

set(h, 'Selection', s.Selection);
set(h, 'SubSelection', s.SubSelection);

% [EOF]

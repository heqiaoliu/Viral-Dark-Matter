function setstate(this, state)
%SETSTATE   Set the state of the object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:11:13 $

set(this, rmfield(state, 'ResponseType'));

% [EOF]

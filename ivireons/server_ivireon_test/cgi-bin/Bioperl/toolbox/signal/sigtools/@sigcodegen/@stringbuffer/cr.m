function cr(this)
%CR Adds a carriage return.
%   H.CR Adds a carriage return to the string buffer.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:32 $

this.buffer = [this.buffer {''}];

% [EOF]
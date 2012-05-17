function b = isempty(this)
%ISEMPTY Returns true if the buffer is empty.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:39 $

b = this.lines == 0;

% [EOF]

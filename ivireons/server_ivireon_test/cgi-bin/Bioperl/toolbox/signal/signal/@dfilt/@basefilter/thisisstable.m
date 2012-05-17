function b = thisisstable(this)
%THISISSTABLE   Dispatch and call the method..

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:04:10 $

error(generatemsgid('AbstractFunction'),[class(this) ' must implement a THISISSTABLE method.']);

% [EOF]

%MLOCK Prevent M-file or MEX-file from being cleared.
%   MLOCK locks the currently running M-file or MEX-file in memory so 
%   that subsequent CLEAR commands do not remove it.
%
%   Use the command MUNLOCK or MUNLOCK(FUN) to return the M-file or 
%   MEX-file to its normal CLEAR-able state.
%
%   Locking an M-file or MEX-file in memory also prevents any PERSISTENT 
%   variables defined in the file from getting reinitialized.
%
%   See also MUNLOCK, MISLOCKED, PERSISTENT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2005/06/27 22:49:57 $
%   Built-in function.

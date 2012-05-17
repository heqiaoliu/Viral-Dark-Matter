%MUNLOCK Allow M-file or MEX-file to be cleared.
%   MUNLOCK(FUN) unlocks the M-file or MEX-file named FUN from memory.
%   so that subsequent CLEAR commands can remove it.  These files are, 
%   unlocked by default so that changes to the file are picked up.  
%   Calls to MUNLOCK are only needed to unlock M-files or MEX-files 
%   that have been locked with the MLOCK function.
%
%   MUNLOCK, by itself, unlocks the currently running M-file or MEX-file.
%
%   See also MLOCK, MISLOCKED.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2005/06/27 22:49:58 $
%   Built-in function.

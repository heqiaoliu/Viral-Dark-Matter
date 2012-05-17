%EXIST  Check if variables or functions are defined.
%   EXIST('A') returns:
%     0 if A does not exist
%     1 if A is a variable in the workspace
%     2 if A is an M-file on MATLAB's search path.  It also returns 2 when
%          A is the full pathname to a file or when A is the name of an
%          ordinary file on MATLAB's search path
%     3 if A is a MEX-file on MATLAB's search path
%     4 if A is a MDL-file on MATLAB's search path
%     5 if A is a built-in MATLAB function
%     6 if A is a P-file on MATLAB's search path
%     7 if A is a directory
%     8 if A is a class (EXIST returns 0 for Java classes if you
%       start MATLAB with the -nojvm option.)
%
%   EXIST('A') or EXIST('A.EXT') returns 2 if a file named 'A' or 'A.EXT'
%   and the extension isn't a P or MEX function extension.
%
%   EXIST('A','var') checks only for variables.
%   EXIST('A','builtin') checks only for built-in functions.
%   EXIST('A','file') checks for files or directories.
%   EXIST('A','dir') checks only for directories.
%   EXIST('A','class') checks only for classes.
%
%   If A specifies a filename, MATLAB attempts to locate the file, 
%   examines the filename extension, and determines the value to 
%   return based on the extension alone.  MATLAB does not examine 
%   the contents or internal structure of the file.
%
%   When searching for a directory, MATLAB finds directories that are part
%   of MATLAB's search path.  They can be specified by a partial path.  It
%   also finds the current working directory specified by a partial path,
%   and subdirectories of the current working directory specified by
%   a relative path.
%
%   EXIST returns 0 if the specified instance isn't found.
%
%   See also DIR, WHAT, ISEMPTY, PARTIALPATH.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.21.4.7 $  $Date: 2009/12/14 22:25:34 $
%   Built-in function.

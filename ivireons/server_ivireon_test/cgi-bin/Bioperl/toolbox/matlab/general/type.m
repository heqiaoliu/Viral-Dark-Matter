%TYPE List M-file.
%   TYPE foo.bar lists the ascii file called 'foo.bar'.
%   TYPE foo lists the ascii file called 'foo.m'. 
%
%   If files called foo and foo.m both exist, then
%      TYPE foo lists the file 'foo', and
%      TYPE foo.m list the file 'foo.m'.
%
%   TYPE PATHNAME/FUN lists the contents of FUN (or FUN.m) 
%   given a full pathname or a MATLABPATH relative partial 
%   pathname (see PARTIALPATH).
%
%   See also DBTYPE, WHICH, HELP, PARTIALPATH, MORE.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 5.13.4.5 $  $Date: 2006/10/14 12:24:19 $
%   Built-in function.

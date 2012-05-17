function status = isAbsolute(file)
%ISABSOLUTE Determines if a filename is absolute.
%
%   ISABSOLUTE returns true if FILE is an absolute name.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2004/11/23 20:39:59 $
if ispc
   status = ~isempty(regexp(file,'^[a-zA-Z]*:\/','once')) ...
            || ~isempty(regexp(file,'^[a-zA-Z]*:\\','once')) ...
            || strncmp(file,'\\',2) ...
            || strncmp(file,'//',2);
else
   status = strncmp(file,'/',1);
end


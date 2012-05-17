function pctunsetenv( name )
; %#ok Undocumented

% This function will unset an environment variable explicitly on all platforms

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/11/24 14:57:12 $

if isunix
    % On unix we need to explicitly call unsetenv c-code
    pct_unsetenvmex( name );
else
    % On windows we should call setenv with no value to unset the variable
    setenv( name );
end
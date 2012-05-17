function defaultUsername = pGetDefaultUsername()
; %#ok Undocumented
% Get the username of the user who started MATLAB.

% Copyright 2009 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2009/12/22 18:51:28 $ 

import com.mathworks.toolbox.distcomp.auth.credentials.UserIdentity;
defaultUserIdentity = UserIdentity.createDefaultUserIdentity();
defaultUsername = char(defaultUserIdentity.getSimpleUsername());

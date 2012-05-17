function changePassword(jm, simpleUsername)
%changePassword  Prompt the user to change the password
%
%    changePassword(jm) prompts the user to change the password for the current
%    user. The user's current password must be entered as well as the new
%    password.
%    
%    changePassword(jm, username) prompts the job manager's admin user to change
%    the password for specified user. The admin user's password must be entered
%    as well as the user's new password. This enables the admin user to reset a
%    password if the user has forgotten it.
%
%    See also distcomp.jobmanager/clearLocalPassword

% Copyright 2009-2010 The MathWorks, Inc.

% $Revision: 1.1.6.1.2.1 $    $Date: 2010/06/17 14:11:46 $ 

import com.mathworks.toolbox.distcomp.auth.credentials.UserIdentity;
if nargin > 1
    userIdentity = UserIdentity(simpleUsername);
else
    userIdentity = [];
end

jobManagerProxy = jm.ProxyObject;
try
    jobManagerProxy.changeCredentialsOfExistingUser(userIdentity);
catch err
    throw(distcomp.handleJavaException(jm, err));
end

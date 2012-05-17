function clearLocalPassword(jm)
%clearLocalPassword Clear a current user's password from this computer.
%
%    clearLocalPassword(jm) clears the current user's password on this computer.
%
%    When you call a privileged action on a job manager you are authenticated by
%    entering your password. To prevent having to enter it for every subsequent
%    privileged action, you can choose to have a token representing your
%    password stored on the local computer. This method removes this token from
%    the store. This means any subsequent call to a privileged action on this
%    computer requires you to re-authenticate with a valid password. This may be
%    useful after you have finished working on a shared machine on which you
%    have previously entered your password.
%
%    See also distcomp.jobmanager/changePassword

% Copyright 2009-2010 The MathWorks, Inc.

% $Revision: 1.1.8.2 $    $Date: 2010/06/24 19:32:55 $ 

jobManagerProxy = jm.ProxyObject;
try
    % Empty UserIdentity means "current user"
    userIdentity = [];
    jobManagerProxy.revokeAuthentication(userIdentity);
catch err
    throw(distcomp.handleJavaException(jm, err));
end

function val = pGetUserName(jm, val)
; %#ok Undocumented
% Get the username of the user currently set in the jobmanager.

%  Copyright 2009-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/02/25 08:01:28 $ 

proxyManager = jm.ProxyObject;
try
    userIdentity = proxyManager.getCurrentUser();
    if isempty(userIdentity)
        val = [];
    else
        val = char(userIdentity.getSimpleUsername());
    end
catch err %#ok<NASGU>
    % Do nothing.
end

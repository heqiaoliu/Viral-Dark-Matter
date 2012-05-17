function val = pIsUsingSecureCommunication(obj, val)
; %#ok Undocumented
%pIsUsingSecureCommunication Check whether scheduler is using secure communication
%
%  VAL = pIsUsingSecureCommunication(OBJ, VAL)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/04/15 22:58:27 $ 

proxyManager = obj.ProxyObject;
try
    val = proxyManager.isUsingSecureCommunication();
catch err %#ok<NASGU>
    % Do nothing.
end

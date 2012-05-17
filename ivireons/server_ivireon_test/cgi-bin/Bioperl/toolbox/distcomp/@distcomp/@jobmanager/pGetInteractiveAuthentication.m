function val = pGetInteractiveAuthentication(jm, ~)
; %#ok Undocumented
%PGETINTERACTIVEAUTHENTICATION
%
%  VAL = PGETINTERACTIVEAUTHENTICATION(JM, VAL)

%  Copyright 2009-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2010/03/22 03:41:53 $ 

proxyManager = jm.ProxyObject;
try
    val = proxyManager.getCredentialConsumerFactory().isInteractive();
catch err %#ok<NASGU>
    % Do nothing.
    val = false;
end

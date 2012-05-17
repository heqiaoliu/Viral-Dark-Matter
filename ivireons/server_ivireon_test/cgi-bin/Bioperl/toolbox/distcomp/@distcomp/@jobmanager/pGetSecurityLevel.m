function val = pGetSecurityLevel(jm, ~)
; %#ok Undocumented
%pGetSecurityLevel Get the security level set in the current mdce

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2010/03/01 05:20:11 $ 

proxyManager = jm.ProxyObject;
try
    val = proxyManager.getSecurityLevel();
catch err %#ok<NASGU>
    % Do nothing.
    val = -1;
end

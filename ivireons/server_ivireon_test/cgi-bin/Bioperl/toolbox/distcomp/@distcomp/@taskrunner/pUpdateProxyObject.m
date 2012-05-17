function pUpdateProxyObject(objs, proxies)
; %#ok Undocumented
%pUpdateProxyObject insert a new java proxy object into this UDD wrapper
%
%  pUpdateProxyObject(OBJS, PROXIES)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:39:45 $ 

% Defer the setting of the DataLocation to the hidden property Storage
objs.Storage = handle(proxies.getStorageLocation);
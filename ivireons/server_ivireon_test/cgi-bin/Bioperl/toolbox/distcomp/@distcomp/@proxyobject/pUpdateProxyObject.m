function pUpdateProxyObject(objs, proxies)
; %#ok Undocumented
%pUpdateProxyObject insert a new java proxy object into this UDD wrapper
%
%  pUpdateProxyObject(OBJS, PROXIES)

%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2006/06/27 22:38:41 $ 

for i = 1:numel(objs)
    objs(i).ProxyObject = proxies(i);
end
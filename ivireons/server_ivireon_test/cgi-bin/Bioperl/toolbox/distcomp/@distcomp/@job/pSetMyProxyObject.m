function pSetMyProxyObject(job, event)
; %#ok Undocumented
%pSetMyProxyObject 
%
%  pSetMyProxyObject(src, event)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:37:12 $ 

parent = event.NewParent;
proxy = parent.pGetJobAccessProxy;
job.ProxyObject = proxy;
job.HasProxyObject = true;

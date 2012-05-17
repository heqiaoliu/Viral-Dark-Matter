function pSetMyProxyObject(task, event)
; %#ok Undocumented
%pSetMyProxyObject 
%
%  pSetMyProxyObject(src, event)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:39:35 $ 

job = event.NewParent;
proxy = job.pGetTaskAccessProxy;
task.ProxyObject = proxy;
task.HasProxyObject = true;

function pSetMyProxyObject( job, event )
; %#ok Undocumented
%pSetMyProxyObject - use parallel job access proxy

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:38:29 $ 

parent          = event.NewParent;
proxy           = parent.pGetParallelJobAccessProxy;
job.ProxyObject = proxy;
job.HasProxyObject = true;
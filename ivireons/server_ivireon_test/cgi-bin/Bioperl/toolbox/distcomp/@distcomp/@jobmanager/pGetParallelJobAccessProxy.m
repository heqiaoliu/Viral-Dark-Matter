function parallelJobAccessProxy = pGetParallelJobAccessProxy(obj)
; %#ok Undocumented
%pGetParallelJobAccessProxy - get the parallel job access proxy
%  
%  proxy = pGetParallelJobAccessProxy(jm)
%  this is used by a distcomp.paralleljob

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.12.3 $    $Date: 2006/06/27 22:37:37 $ 

parallelJobAccessProxy = obj.ParallelJobAccessProxy;

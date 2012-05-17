function firehierarchychanged(h)
%HIERARCHYCHANGED   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:05 $

%public because it is called from subsysnode and blkdgmnode
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('HierarchyChangedEvent', h)

% [EOF]
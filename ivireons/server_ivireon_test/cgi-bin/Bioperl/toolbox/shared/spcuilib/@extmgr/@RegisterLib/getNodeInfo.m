function nodeInfo = getNodeInfo(this)
%GETNODEINFO Get the nodeInfo.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:13 $

nodeInfo.Title = 'Library Details';
nodeInfo.Widgets = {'Number of databases' sprintf('%d', numChild(this))};
    
% [EOF]

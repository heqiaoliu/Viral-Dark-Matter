function nodeInfo = getNodeInfo(this)
%GETNODEINFO Get the nodeInfo.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:31 $

nodeInfo.Title = 'Property';
nodeInfo.Widgets = { ...
    'Name'   this.Name; ...
    'Status' this.Status; ...
    'Value'  mat2str(this.Value)};

% [EOF]

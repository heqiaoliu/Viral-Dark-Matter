function nodeInfo = getNodeInfo(this)
%GETNODEINFO Get the nodeInfo.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:01 $

nodeInfo.Title   = 'Registration Database Details';
nodeInfo.Widgets = { ...
    'Filename'             this.FileName; ...
    'Number of extensions' sprintf('%d', this.numChild)};

% [EOF]

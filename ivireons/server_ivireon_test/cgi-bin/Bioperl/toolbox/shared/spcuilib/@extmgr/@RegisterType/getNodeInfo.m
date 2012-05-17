function nodeInfo = getNodeInfo(this)
%GETNODEINFO Get the nodeInfo.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:02:34 $

nodeInfo.Title = 'Registration Type';
nodeInfo.Widgets = { ...
    'Type'        this.Type; ...
    'Constraints' class(this.Constraint)};

% [EOF]

function parent = set_Parent(this, parent)
%SET_PARENT PreSet function for the 'Parent' property

%   @commgui/@abstractGUI
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:29 $

if ~ishghandle(parent)
    error([this.getErrorId ':InvalidParent'], ...
        'Parent must be a valid handle.');
end    

% Set PrivParent.  Note that Parent is the phantom property of PrivParent.
this.PrivParent = parent;

%-------------------------------------------------------------------------------
% [EOF]

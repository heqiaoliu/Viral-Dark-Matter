function addPost(this, theChild, childIdx) %#ok
%ADDPOST  <short description>
%   OUT = ADDPOST(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:07:31 $

if ~isempty(this.hWidget)
    this.hWidget.addGroup(theChild.hKeyGroup);
end

% [EOF]

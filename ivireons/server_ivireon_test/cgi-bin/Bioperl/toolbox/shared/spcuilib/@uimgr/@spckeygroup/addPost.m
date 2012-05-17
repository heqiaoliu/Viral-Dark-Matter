function addPost(this, theChild, childIndx) %#ok
%ADDPOST  <short description>
%   OUT = ADDPOST(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/23 19:07:27 $

if ~isempty(theChild)
    this.hKeyGroup.addBinding(theChild.hKeyBinding);
end

% [EOF]

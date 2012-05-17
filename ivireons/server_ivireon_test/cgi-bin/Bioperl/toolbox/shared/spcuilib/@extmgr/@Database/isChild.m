function b = isChild(this, hTestChild)
%ISCHILD  True if the object is Child

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:50 $

% If the parent of the object we are testing is the database, the object is
% one of our children.
hTestParent = hTestChild.up;
if isempty(hTestParent)
    b = false;
else
    b = hTestParent == this;
end

% [EOF]

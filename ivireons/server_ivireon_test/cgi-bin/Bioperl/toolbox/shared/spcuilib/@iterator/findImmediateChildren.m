function hFound = findImmediateChildren(hParent, matchFcn)
%FINDIMMEDIATECHILDREN Finds all immediate children matching the function.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/23 19:03:44 $

hFound = [];
hChild = hParent.down;
while ~isempty(hChild)
    if matchFcn(hChild)
        hFound = [hFound hChild]; %#ok
    end
    hChild = hChild.right;
end

% [EOF]

function hChildren = allchild(hParent)
%ALLCHILD Return the children of this object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:03:26 $

% Get all the children of the object
hChildren = find(hParent, '-depth', 1);

% Remove the first element which is hParent
hChildren(1) = [];

hChildren = [hChildren(:)]';

% [EOF]

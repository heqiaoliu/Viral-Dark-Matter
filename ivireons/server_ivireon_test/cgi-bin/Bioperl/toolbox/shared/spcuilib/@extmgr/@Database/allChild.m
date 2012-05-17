function hChild = allChild(this)
%ALLCHILD Return the handles to all of the database's children.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:45 $

cClass = getChildClass(this);

% Check if we are looking for 'handle' ourselves.  We cannot rely on the
% '-isa' flag because of g351549.
if strcmpi(cClass, 'handle')
    hChild = find(this, '-depth', 1);
else
    hChild = find(this, '-depth', 1, '-isa', cClass);
end

% If cClass is an abstract class that THIS extends, FIND will return it as
% the first output.  Check to make sure that the first output is not THIS
% object.  If it is, remove it from the vector.
if ~isempty(hChild) && hChild(1) == this
    hChild(1) = [];
end

% [EOF]

function checkBinaryColVec(h, prop, value)
%CHECKBINCOLVEC Check if value is a binary column vector
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:10:50 $

if ischar(h)
    msg = sprintf(['The %s input argument of %s must be a binary column ' ...
        'vector.'], prop, h);
else
    msg = sprintf(['The ''%s'' property of ''%s'' must be a binary column ', ...
        'vector.'], prop, class(h));
end

[m n] = size(value);
if islogical(value)
    if (n~=1)
        throwAsCaller(MException('MATLAB:datatypes:NotBinaryColVec', msg));
    end
else
    if (n~=1) || ~isnumeric(value) || any((value~=0)&(value~=1))
        throwAsCaller(MException('MATLAB:datatypes:NotBinaryColVec', msg));
    end
end
%---------------------------------------------------------------------------
% [EOF]
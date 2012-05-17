function checkFiniteDblMat(h, prop, value, reqSize)
%CHECKFINITEDBLMAT Check if value is a finite double matrix
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/21 16:29:38 $

[m, n] = size(value);

% Note that if any of the sizes is 1, then it is a vector.  Currently works only
% with 2D matrices.
if reqSize(1)==1
    type = 'row vector';
elseif reqSize(2)==1
    type = 'column vector';
else
    type = 'matrix';
end

if  (m~=reqSize(1)) || (n~=reqSize(2)) || ~isa(value, 'double') ...
        || any(any(isinf(value))) || any(any(isnan(value)))
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite '...
            'double %s of size %dx%d.'], prop, h, type, reqSize(1), ...
            reqSize(2));
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite '...
            'double %s of size %dx%d.'], prop, class(h), type, reqSize(1), ...
            reqSize(2));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteDblMat', msg));
end
%---------------------------------------------------------------------------
% [EOF]
function checkFiniteDblRowVec(h, prop, value)
%CHECKFINITEDBLROWVEC Check if value is a finite double row vector
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/08/22 20:31:46 $

if  (size(value,1)~=1) || ~isa(value, 'double') || any(isinf(value)) ...
        || any(isnan(value))

    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite double '...
            'row vector.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite '...
            'double row vector.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteDblRowVec', msg));
end
%---------------------------------------------------------------------------
% [EOF]
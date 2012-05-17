function checkFiniteRealDblColVec(h, prop, value)
%CHECKFINITEREALDBLCOLVEC Check if value is a finite real double column vector
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/04/21 16:29:40 $

[m, n] = size(value);
if  (n~=1) || ~isa(value, 'double') || any(isinf(value)) ...
        || any(isnan(value)) || ~isreal(value)

    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite real '...
            'double column vector.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite real '...
            'double column vector.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteRealDblColVec', msg));
end
%---------------------------------------------------------------------------
% [EOF]
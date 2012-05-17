function checkFiniteRealDblVec(h, prop, value)
%CHECKFINITEREALDBLVEC Check if value is a finite real double vector
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/02 19:04:18 $
[m, n] = size(value);

%Empty vectors may be still considered vectors
if ~(m == 0 && n == 0)
    if ~(m == 1 || n == 1) || ~isa(value, 'double') || any(isinf(value)) ...
            || any(isnan(value)) || ~isreal(value)

        if ischar(h)
            msg = sprintf(['The %s input argument of %s must be a finite real '...
                'double vector.'], prop, h);
        else
            msg = sprintf(['The ''%s'' property of ''%s'' must be a finite real '...
                'double vector.'], prop, class(h));
        end
        throwAsCaller(MException('MATLAB:datatypes:NotFiniteRealDblVec', msg));
    end
end
%---------------------------------------------------------------------------
% [EOF]
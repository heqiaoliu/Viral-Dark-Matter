function checkFiniteDbl(h, prop, value)
%CHECKFINITEDBL Check if value is finite double
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.
%
%   The size of VALUE is unimportant as long as all the elemnts in VALUE
%   are finite and double.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/08/22 20:31:45 $

if  ~isa(value, 'double') || any(any(isinf(value))) ||...
        any(any(isnan(value)))
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be finite and '...
            'double.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be finite '...
            'and double.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteDbl', msg));
end
%---------------------------------------------------------------------------
% [EOF]

function checkNumericOrLogicalScalar(h, prop, value)
%checkNumericOrLogicalScalar Check if value is a numeric or logical scalar
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/06 13:32:28 $

if ~isscalar(value) || ~(islogical(value) || isnumeric(value))
    if ischar(h)
        msg = sprintf('The %s input argument of %s must be a numeric or logical scalar.', ...
            prop, h);
    else
        msg = sprintf('The ''%s'' property of ''%s'' must be a numeric or logical scalar.', ...
            prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotNumericOrLogicalScalar', msg));
end
%---------------------------------------------------------------------------

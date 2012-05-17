function checkString(h, prop, value)
%CHECKSTRING Check if value is a scalar
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:11:02 $

if ~ischar(value)
    if ischar(h)
        msg = sprintf('The %s input argument of %s must be a string.', ...
            prop, h);
    else
        msg = sprintf('The ''%s'' property of ''%s'' must be a string.', ...
            prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotString', msg));
end
%---------------------------------------------------------------------------
% [EOF]
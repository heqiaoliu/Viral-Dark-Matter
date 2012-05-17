function checkStringVector(h, prop, value)
%CHECKSTRINGVECTOR Check if value is a cell array of strings.
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/07/09 18:13:01 $

if ~iscellstr(value)
    if ischar(h)
        msg = sprintf('The %s input argument of %s must be a cell array of string.', ...
            prop, h);
    else
        msg = sprintf('The ''%s'' property of ''%s'' must be a cell array of string.', ...
            prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotStringVector', msg));
end

% [EOF]

function checkLogical(h, prop, value)
%CHECKLOGICAL Check if value is a logical.
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/07/09 18:12:59 $

if ischar(h)
    msg = sprintf('The %s input argument of %s must be a logical.', prop, h);
else
    msg = sprintf('The ''%s'' property of ''%s'' must be a logical.', prop, class(h));
end

if ~islogical(value)
    throwAsCaller(MException('MATLAB:datatypes:NotLogical', msg));
end

% [EOF]
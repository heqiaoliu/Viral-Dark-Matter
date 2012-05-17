function checkLogicalScalar(h, prop, value)
%CHECKLOGICALSCALAR Check if value is a scalar logical.
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/07/09 18:13:00 $

if ischar(h)
    msg = sprintf('The %s input argument of %s must be a scalar logical.', prop, h);
else
    msg = sprintf('The ''%s'' property of ''%s'' must be a scalar logical.', prop, class(h));
end

if ~islogical(value) || any(size(value) ~= 1)
    throwAsCaller(MException('MATLAB:datatypes:NotLogicalScalar', msg));
end

% [EOF]

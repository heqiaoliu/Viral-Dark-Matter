function checkFinitePosIntScalar(h, prop, value)
%CHECKFINITEPOSINTSCALAR Check if value is a finite positive integer scalar
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:10:59 $

% Note that int MATLAB types are not covered.  We are checking for integer
% numbers represented by double variables.
if ~isscalar(value) || ~isa(value, 'double') || isinf(value) || ...
        isnan(value) || (value <= 0) || ~isreal(value) || ...
        (floor(value)~=value)
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite '...
            'positive scalar integer.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite '...
            'positive scalar integer.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFinitePosIntScalar', msg));
end
%---------------------------------------------------------------------------
% [EOF]
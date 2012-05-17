function checkFiniteRealDblScalar(h, prop, value)
%CHECKFINITEREALDBLSCALAR Check if value is a finite real double scalar
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/04/21 16:29:42 $

if ~isscalar(value) || ~isa(value, 'double') || isinf(value) || ...
        isnan(value) || ~isreal(value)
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite real '...
            'scalar double.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite real '...
            'scalar double.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFiniteRealDblScalar', msg));
end
%---------------------------------------------------------------------------
% [EOF]
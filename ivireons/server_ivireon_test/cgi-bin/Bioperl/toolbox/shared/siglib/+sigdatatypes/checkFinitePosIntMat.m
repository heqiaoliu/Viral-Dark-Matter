function checkFinitePosIntMat(h, prop, value, reqSize)
%CHECKFINITEPOSINTMAT Check if value is a finite positive integer matrix
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.
%
%   Example:
%       sigdatatypes.checkFinitePosIntMat('foo','x',[2 3;3 2],[2 2]);

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/05/23 08:11:35 $

[m, n] = size(value);

% Note that if any of the sizes is 1, then it is a vector.  Currently works only
% with 2D matrices.
if reqSize(1)==1
    type = 'row vector';
elseif reqSize(2)==1
    type = 'column vector';
else
    type = 'matrix';
end

if  (m~=reqSize(1)) || (n~=reqSize(2)) || ~isa(value, 'double') ...
        || any(any(value<=0)) || any(any(isinf(value))) ...
        || any(any(isnan(value))) || ~isreal(value) ...
        || any(floor(value(:))~=value(:))
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite '...
            'positive integer %s of size %dx%d.'], prop, h, type, reqSize(1), ...
            reqSize(2));
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite '...
            'positive integer %s of size %dx%d.'], prop, class(h), type,  ...
            reqSize(1), reqSize(2));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotFinitePosIntMat', msg));
end
%---------------------------------------------------------------------------
% [EOF]
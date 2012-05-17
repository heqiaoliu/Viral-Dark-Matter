function checkSpaceAngle(h, prop, value)
%CHECKSPACEANGLE Check if value is a valid space angle matrix (vector)
%   If H is a class handle, then a message that includes property name PROP
%   and class name of H is issued.  If H is a string, then a message that
%   assumes PROP is an input argument to a function or method is issued.
%
%   Space angle is a 2xN matrix with each column specifying a
%   [AzimuthAngle; ElevationAngle] pair. All elevation angles must be
%   within [-90 90] and all azimuth angles must be within [-180 180].
%   
%   Example:
%       sigdatatypes.checkSpaceAngle('foo','x',[30;60]);

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/31 06:58:06 $

m = size(value,1);

% Note that if any of the sizes is 1, then it is a vector.  Currently works only
% with 2D matrices.

if  (m~=2) ||  ~isa(value, 'double') || ~isreal(value) ...
        || any(any(isinf(value))) || any(any(isnan(value))) ...
        || any(value(1,:) < -180) || any(value(1,:) > 180) ...
        || any(value(2,:) < -90) || any(value(2,:) > 90)
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be a finite real '...
            'double matrix or vector with two rows. All entries in '...
            'the first row must be within [-180 180] and all entries in '...
            'the second row must be within [-90 90].'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be a finite real '...
            'double matrix or vector with two rows. All entries in '...
            'the first row must be within [-180 180] and all entries in '...
            'the second row must be within [-90 90].'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:NotSpaceAngle', msg));
end
%---------------------------------------------------------------------------

% [EOF]

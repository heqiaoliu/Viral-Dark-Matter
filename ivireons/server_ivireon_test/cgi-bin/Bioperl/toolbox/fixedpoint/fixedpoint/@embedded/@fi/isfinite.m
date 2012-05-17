function t = isfinite(this)
%ISFINITE True for finite elements
%   Refer to the MATLAB ISFINITE reference page for more information.
%
%   See also ISFINITE

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/06/18 22:16:42 $

if isfixed(this) || isboolean(this)
    % fixed-point values and booleans are always finite
    t = true(size(this));
else
    t = isfinite(double(this));
end

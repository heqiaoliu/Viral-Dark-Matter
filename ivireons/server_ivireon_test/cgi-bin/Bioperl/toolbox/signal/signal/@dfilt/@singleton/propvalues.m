function coeffs = propvalues(this)
%PROPVALUES   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:27:09 $

coeffs = coefficients(reffilter(this));

% [EOF]

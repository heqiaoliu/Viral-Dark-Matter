function flag = isValidDistributionDimension(x)

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:07:03 $

flag = isscalar(x) && isPositiveIntegerValuedNumeric(x);

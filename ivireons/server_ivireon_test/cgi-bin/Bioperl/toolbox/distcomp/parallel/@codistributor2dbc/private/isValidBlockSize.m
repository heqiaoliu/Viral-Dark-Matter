function flag = isValidBlockSize(x)

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:56:47 $

flag = isscalar(x) && isPositiveIntegerValuedNumeric(x);

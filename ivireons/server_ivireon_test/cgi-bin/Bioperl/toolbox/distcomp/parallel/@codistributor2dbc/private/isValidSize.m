function flag = isValidSize(x)

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:56:49 $

flag = isRowVectorWithLength(x,2) && isPositiveIntegerValuedNumeric(x,true);

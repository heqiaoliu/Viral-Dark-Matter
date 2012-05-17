function flag = isValidDistributionPartition(x)

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/24 17:04:15 $

flag = isRowVectorWithLength(x,numlabs) && isPositiveIntegerValuedNumeric(x,true);

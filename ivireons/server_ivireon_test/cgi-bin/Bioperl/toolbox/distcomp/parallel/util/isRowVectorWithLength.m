function flag = isRowVectorWithLength(x,n)

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:27:50 $
flag = isvector(x) && isequal(size(x,1),1) && isequal(size(x,2),n);

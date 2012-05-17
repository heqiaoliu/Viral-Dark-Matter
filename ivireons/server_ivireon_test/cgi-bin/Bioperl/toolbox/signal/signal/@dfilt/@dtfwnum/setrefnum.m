function num = setrefnum(Hd, num)
%SETREFNUM Overloaded set on the refnum property.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:03:38 $

validaterefcoeffs(Hd.filterquantizer, 'Numerator', num);

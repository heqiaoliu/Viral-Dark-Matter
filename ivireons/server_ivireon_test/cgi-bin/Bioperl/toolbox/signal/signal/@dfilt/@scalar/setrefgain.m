function g = setrefgain(Hd, g)
%SETREFGAIN Overloaded set on the refgain property.
  
%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/12 23:59:21 $

validaterefcoeffs(Hd.filterquantizer, 'Gain', g);

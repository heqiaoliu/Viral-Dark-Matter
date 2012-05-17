function den = setrefden(Hd, den)
%SETREFNUM Overloaded set on the refden property.
  
%   Author: P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2004/03/15 22:27:41 $

validaterefcoeffs(Hd.filterquantizer, 'Denominator', den);

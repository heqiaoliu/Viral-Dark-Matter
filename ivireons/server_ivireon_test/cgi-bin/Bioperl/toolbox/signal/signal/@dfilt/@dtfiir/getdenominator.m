function den = getdenominator(Hd, den)
%GETDENOMINATOR Overloaded get on the Denominator property.
  
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:56:53 $

den = getdenominator(Hd.filterquantizer,Hd.privden);

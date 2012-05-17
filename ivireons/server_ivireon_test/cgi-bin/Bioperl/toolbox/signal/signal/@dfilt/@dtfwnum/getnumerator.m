function num = getnumerator(Hd, num)
%GETNUMERATOR Overloaded get on the Numerator property.
  
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:57:02 $

num = getnumerator(Hd.filterquantizer, Hd.privnum);

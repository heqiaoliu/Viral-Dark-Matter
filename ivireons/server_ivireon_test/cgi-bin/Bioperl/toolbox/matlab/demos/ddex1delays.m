function d = ddex1delays(t,y)
%DDEX1DELAYS  Delays for using with DDEX1DE.
%
%   See also DDESD.

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:14:35 $

d = [ t - 1
      t - 0.2];


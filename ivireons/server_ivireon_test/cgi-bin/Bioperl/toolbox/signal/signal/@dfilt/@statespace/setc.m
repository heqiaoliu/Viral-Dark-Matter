function C = setc(Hd, C)
%SETC Overloaded set function on the C property.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:41 $
  
set(Hd,'refC',C);
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
C = [];


function B = setb(Hd, B)
%SETB Overloaded set function on the B property.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:40 $
  
set(Hd,'refB',B);
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
B = [];

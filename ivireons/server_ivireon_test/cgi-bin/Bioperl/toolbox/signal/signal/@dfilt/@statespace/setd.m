function D = setd(Hd, D)
%SETD Overloaded set function on the D property.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:42 $

set(Hd,'refD',D);
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
D = [];

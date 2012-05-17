function g = setgain(Hd, g)
  

%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 18:58:56 $

% Check data type and store Gain as reference
set(Hd,'refgain',g);

set_ncoeffs(Hd.filterquantizer, 1);

% Quantize the gain
quantizecoeffs(Hd);

% clear metadata
clearmetadata(Hd);

% Hold an empty to not duplicate storage
g = [];

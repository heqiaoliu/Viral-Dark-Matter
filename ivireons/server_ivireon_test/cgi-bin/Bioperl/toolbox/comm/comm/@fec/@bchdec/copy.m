function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @fec\@bchdec

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:06:49 $

h = fec.bchdec;

h = bchcon(h, refObj);

h.PrivGfTable1 = refObj.PrivGfTable1;
h.PrivGfTable2 = refObj.PrivGfTable2;

%-------------------------------------------------------------------------------

% [EOF]

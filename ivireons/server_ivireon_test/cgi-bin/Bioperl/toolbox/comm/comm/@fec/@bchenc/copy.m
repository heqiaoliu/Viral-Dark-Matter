function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @fec\@bchenc

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:21:43 $

h = fec.bchenc;

h = bchcon(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]

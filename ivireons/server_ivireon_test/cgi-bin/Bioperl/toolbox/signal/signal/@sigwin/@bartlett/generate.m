function data=generate(hWIN)
%GENERATE(hWIN) Generates the Bartlett window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:05:14 $

data = bartlett(hWIN.length);

% [EOF]

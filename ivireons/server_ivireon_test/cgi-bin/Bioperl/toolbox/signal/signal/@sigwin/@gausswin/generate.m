function data=generate(hWIN)
%GENERATE(hWIN) Generates the Gaussian window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:06:08 $

data = gausswin(hWIN.length, hWIN.Alpha);

% [EOF]

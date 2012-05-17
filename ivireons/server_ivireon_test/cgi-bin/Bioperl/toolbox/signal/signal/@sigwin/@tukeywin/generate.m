function data=generate(hWIN)
%GENERATE(hWIN) Generates the Tukey window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:07:50 $

data = tukeywin(hWIN.length, hWIN.Alpha);

% [EOF]

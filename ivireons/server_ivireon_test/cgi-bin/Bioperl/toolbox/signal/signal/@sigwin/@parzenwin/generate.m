function data=generate(hWIN)
%GENERATE(hWIN) Generates the Parzen window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:07:11 $

data = parzenwin(hWIN.length);

% [EOF]

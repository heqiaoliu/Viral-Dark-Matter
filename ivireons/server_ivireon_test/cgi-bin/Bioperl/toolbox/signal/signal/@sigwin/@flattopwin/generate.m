function data = generate(hWIN)
%GENERATE Generates the Flat Top window

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:16:21 $

data = flattopwin(hWIN.length, hWIN.SamplingFlag);

% [EOF]

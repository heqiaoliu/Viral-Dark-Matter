function data=generate(hWIN)
%GENERATE(hWIN) Generates the Hamming window

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:16:27 $

data = hamming(hWIN.Length, hWIN.SamplingFlag);

% [EOF]

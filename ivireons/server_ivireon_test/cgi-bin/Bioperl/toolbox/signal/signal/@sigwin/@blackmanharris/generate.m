function data=generate(hWIN)
%GENERATE(hWIN) Generates the Blackman-Harris window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:05:32 $

data = blackmanharris(hWIN.length);

% [EOF]

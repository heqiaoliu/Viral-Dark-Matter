function specs = fps_whichspecs(h)
%FPS_WHICHSPECS

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:21 $

% Call super's method
specs = fs1_whichspecs(h);

% Prop name, data type, default value, listener callback
specs(end+1) = cell2struct({'Fpass','udouble',14000,[],'freqspec'},specfields(h),2);

% [EOF]

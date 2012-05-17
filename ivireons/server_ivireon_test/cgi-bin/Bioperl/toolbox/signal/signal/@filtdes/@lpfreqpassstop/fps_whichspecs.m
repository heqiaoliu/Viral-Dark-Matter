function specs = fps_whichspecs(h)
%FPS_WHICHSPECS

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:22:02 $

% Call super's method
specs = fp1_whichspecs(h);

% Prop name, data type, default value, listener callback
specs(end+1) = cell2struct({'Fstop','udouble',12000,[],'freqspec'},specfields(h),2);


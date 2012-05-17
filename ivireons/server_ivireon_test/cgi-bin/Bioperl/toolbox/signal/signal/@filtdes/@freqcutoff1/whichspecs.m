function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:37:06 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'Fc','udouble',10800,[],'freqspec'},specfields(h),2);





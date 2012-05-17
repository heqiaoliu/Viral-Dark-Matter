function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:45:21 $

% Call super's method
specs = mip_whichspecs(h);

% Prop name, data type, default value, listener callback
specs(end+1) = cell2struct({'Astop','udouble',80,[],'magspec'},specfields(h),2);







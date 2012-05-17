function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:34 $

% Call alternate method
specs = mf_whichspecs(h);
specs(end+1) = cell2struct({'Apass','udouble',3,[],'magspec'},specfields(h),2);

% [EOF]

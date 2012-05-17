function s = whichspecs(h)
%WHICHSPECS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:18:48 $

s = [cell2struct({'Fpeak','udouble',9600,[],'freqspec'},specfields(h),2) fin_whichspecs(h)];

% [EOF]

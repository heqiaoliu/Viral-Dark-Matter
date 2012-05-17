function c = cparam(h)
%CPARAM   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:12:29 $

F1 = h.Fstop1;
F2 = h.Fstop2;
c = computecparam(h,F1,F2);

% [EOF]

function c = computecparam(h,F1,F2)
%COMPUTECPARAM   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:11:04 $

c = sin(pi*(F1+F2))/(sin(pi*F1)+sin(pi*F2));

% [EOF]

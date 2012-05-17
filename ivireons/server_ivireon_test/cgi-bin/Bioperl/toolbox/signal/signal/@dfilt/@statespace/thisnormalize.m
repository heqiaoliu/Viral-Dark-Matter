function g = thisnormalize(Hd)
%THISNORMALIZE   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:46 $

B = Hd.refB;
C = Hd.refC;
D = Hd.refD;
g = [max(abs(B)) max(abs(C)) max(abs(D))];
Hd.refB = B/g(1);
Hd.refC = C/g(2);
Hd.refD = D/g(3);

% [EOF]

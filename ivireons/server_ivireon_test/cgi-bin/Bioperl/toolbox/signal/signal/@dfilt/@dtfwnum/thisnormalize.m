function g = thisnormalize(Hd)
%THISNORMALIZE   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:57:07 $

num = Hd.refnum;
g = max(abs(num));
Hd.refnum= num/g;

% [EOF]

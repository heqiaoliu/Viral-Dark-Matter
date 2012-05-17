function flag = isempty(h)
%ISEMPTY   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:13 $

flag = isempty(h.Numerator) && isempty(h.Denominator); 


% [EOF]

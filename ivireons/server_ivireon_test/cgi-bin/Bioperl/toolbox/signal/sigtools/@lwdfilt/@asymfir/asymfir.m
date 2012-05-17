function H = asymfir(num)
%ASYMFIR   Construct a ASYMFIR object.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:20:08 $

H = lwdfilt.asymfir;

if nargin > 0,
    H.Numerator = num;
    H.refnum = num;
end

% [EOF]

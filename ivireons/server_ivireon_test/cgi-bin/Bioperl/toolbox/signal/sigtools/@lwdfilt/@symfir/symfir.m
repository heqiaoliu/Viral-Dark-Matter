function H = symfir(num)
%SYMFIR   Construct a SYMFIR object.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:20:24 $

H = lwdfilt.symfir;

if nargin > 0,
    H.Numerator = num;
    H.refnum = num;
end

% [EOF]

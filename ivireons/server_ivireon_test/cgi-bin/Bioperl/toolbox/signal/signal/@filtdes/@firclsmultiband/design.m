function Hd = design(h, d)
%DESIGN Design the filter

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:06:47 $

N = get(d, 'Order');

F = get(d, 'FrequencyVector');
A = get(d, 'MagnitudeVector');

Upper = get(d, 'UpperVector');
Lower = get(d, 'LowerVector');

b = fircls(N, F, A, Upper, Lower);

Hd = dfilt.dffir(b);

% [EOF]

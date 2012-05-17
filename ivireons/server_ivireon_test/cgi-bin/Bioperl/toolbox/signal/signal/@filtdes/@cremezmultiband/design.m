function Hd = design(h, d)
%DESIGN Design the filter

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:15:41 $

F = get(d, 'FrequencyVector');
A = get(d, 'MagnitudeVector');
W = get(d, 'WeightVector');

args = getoptionalinputs(d);

b = cremez(get(d, 'Order'), F, {'multiband', A}, W, args{:});
Hd = dfilt.dffir(b);

% [EOF]

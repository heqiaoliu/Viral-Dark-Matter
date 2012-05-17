function Hd = design(h, d)
%DESIGN Design the filter

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:15:19 $

args = getoptionalinputs(d);

b = cremez(get(d, 'Order'), get(d, 'FrequencyVector'), 'hilbfilt', args{:});
Hd = dfilt.dffir(b);

% [EOF]

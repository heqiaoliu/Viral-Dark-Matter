function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2007/12/14 15:12:59 $

args = getarguments(h, d);

N = get(d, 'Order');

% Check for valid order
if rem(N, 2),
    error(generatemsgid('MustBeEven'),'Cannot design filter, try making the order even.');
end

dens = get(d,'DensityFactor');

b = remez(N, args{:}, {dens});

% Construct object
Hd = dfilt.dffir(b);

% [EOF]

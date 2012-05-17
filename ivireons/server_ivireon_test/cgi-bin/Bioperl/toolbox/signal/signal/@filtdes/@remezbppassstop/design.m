function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/03/02 10:23:12 $

args = getarguments(h, d);
dens = get(d,'DensityFactor');

b = remez(get(d, 'Order'), args{:}, {dens});

% Construct object
Hd = dfilt.dffir(b);

% [EOF]

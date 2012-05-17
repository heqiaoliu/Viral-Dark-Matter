function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:16:27 $


% Set up design params
N = get(d,'order');

[F,A,W] = getNumericSpecs(h,d);

b = remez(N,F,A,W,'hilbert');

% Construct object
Hd = dfilt.dffir(b);




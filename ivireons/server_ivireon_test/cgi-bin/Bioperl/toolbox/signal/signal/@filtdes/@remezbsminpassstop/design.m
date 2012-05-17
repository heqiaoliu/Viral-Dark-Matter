function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:39:54 $

[Fpass1 Fstop1 Fstop2 Fpass2 delta1 delta2 delta3] = getdesignspecs(h, d);

F = [Fpass1 Fstop1 Fstop2 Fpass2];
A = [1 0 1];

DEV = [delta1 delta2 delta3];

[N,Fo,Ao,W] = remezord(F,A,DEV);

dens = get(d,'DensityFactor');

b = remez(N,Fo,Ao,W,{dens});

% Construct object
Hd = dfilt.dffir(b);




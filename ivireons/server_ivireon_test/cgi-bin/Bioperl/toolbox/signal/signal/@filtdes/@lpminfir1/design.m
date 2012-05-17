function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:38:25 $

[Fpass, Fstop, delta1, delta2] = getdesignspecs(h, d);

F = [Fpass Fstop];
A = [1 0];

DEV = [delta1 delta2];

[N,Wn,BETA,TYPE] = kaiserord(F,A,DEV);

scaleflag = determinescaleflag(d);

b = fir1(N,Wn,TYPE,kaiser(N+1,BETA),scaleflag);

% Construct object
Hd = dfilt.dffir(b);

% [EOF]

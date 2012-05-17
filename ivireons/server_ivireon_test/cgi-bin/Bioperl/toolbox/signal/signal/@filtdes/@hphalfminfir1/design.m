function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/11/21 15:38:06 $

[Fpass, Dpass] = getdesignspecs(h, d);

b = firhalfband('minorder',1-Fpass,Dpass,'kaiser','high');

% Construct object
Hd = dfilt.dffir(b);

% [EOF]

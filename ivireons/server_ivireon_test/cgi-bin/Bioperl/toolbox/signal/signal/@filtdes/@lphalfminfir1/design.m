function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:38:20 $

[Fpass, Dpass] = getdesignspecs(h, d);

b = firhalfband('minorder',Fpass,Dpass,'kaiser');

% Construct object
Hd = dfilt.dffir(b);

% [EOF]

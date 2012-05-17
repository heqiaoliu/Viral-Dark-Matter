function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:38:18 $


% get passband edge, it has been prenormalized
[Fpass, Dpass] = getdesignspecs(h, d);

b = firhalfband('minorder',Fpass,Dpass);

% Construct object
Hd = dfilt.dffir(b);




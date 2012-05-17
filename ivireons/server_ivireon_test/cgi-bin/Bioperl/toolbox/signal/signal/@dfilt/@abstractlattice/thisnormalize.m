function g = thisnormalize(Hd)
%THISNORMALIZE   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:52:02 $

lat = Hd.reflattice;
g = max(abs(lat));
Hd.reflattice= lat/g;

% [EOF]

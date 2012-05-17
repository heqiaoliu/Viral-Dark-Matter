function reflattice = setreflattice(Hd, reflattice)
%SETREFLATTICE   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:52:00 $

validaterefcoeffs(Hd.filterquantizer, 'Lattice', reflattice);

% [EOF]

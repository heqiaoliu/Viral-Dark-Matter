function lat = getlattice(Hd, lat)
%GETLATTICE Overloaded get on the Lattice property.
  
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/06 16:00:05 $

lat = double(Hd.privlattice);

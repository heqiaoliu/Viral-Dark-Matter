function Hd = dispatch(this)
%DISPATCH   Return the LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:47:49 $

Hd = lwdfilt.tf(latc2tf(this.Lattice));

Hd.refNum = latc2tf(this.refLattice, 'fir');

% [EOF]

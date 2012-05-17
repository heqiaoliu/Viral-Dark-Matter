function Hd = dispatch(this)
%DISPATCH   Return the LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:16 $

[b, a] = latc2tf(this.Lattice, this.Ladder);

Hd = lwdfilt.tf(b, a);

[b, a] = latc2tf(this.refLattice, this.refLadder);

Hd.refnum = b;
Hd.refden = a;

% [EOF]

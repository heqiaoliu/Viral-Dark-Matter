function Hd = dispatch(this)
%DISPATCH   Return the lightweight DFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:13 $

[b, a] = latc2tf(this.Lattice, 'allpass');

Hd = lwdfilt.tf(b, a);

[b, a] = latc2tf(this.refLattice, 'allpass');

set(Hd, 'refnum', b, 'refden', a);

% [EOF]

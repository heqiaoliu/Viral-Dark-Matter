function Hd = dispatch(this)
%DISPATCH   Returns a LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:14 $

[b, a] = latc2tf(this.Lattice, 'allpole');

Hd = lwdfilt.tf(b, a);

[b, a] = latc2tf(this.refLattice, 'allpole');

set(Hd, 'refnum', b, 'refden', a);

% [EOF]

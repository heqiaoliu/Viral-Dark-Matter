function Hd = dispatch(this)
%DISPATCH   Return the LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:09 $

Hd = lwdfilt.tf(this.Numerator, this.Denominator);

set(Hd, 'refnum', this.refnum, ...
    'refden', this.refden);

% [EOF]

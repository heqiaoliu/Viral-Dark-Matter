function Hd = dispatch(this)
%DISPATCH   Return the LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:23 $

[b, a] = ss2tf(this.A, this.B, this.C, this.D);

Hd = lwdfilt.tf(b, a);

% [EOF]

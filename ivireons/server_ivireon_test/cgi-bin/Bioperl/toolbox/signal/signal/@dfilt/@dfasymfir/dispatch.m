function Hd = dispatch(this)
%DISPATCH   Dispatch to the lwdfilt object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:03 $

Hd = lwdfilt.asymfir(this.Numerator);
Hd.refnum = this.refnum;

% [EOF]

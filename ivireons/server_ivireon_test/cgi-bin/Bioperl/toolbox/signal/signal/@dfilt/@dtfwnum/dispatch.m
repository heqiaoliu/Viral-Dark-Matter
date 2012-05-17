function Hd = dispatch(this)
%DISPATCH   Returns the LWDFILT.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:10 $

Hd = lwdfilt.tf(this.Numerator);

Hd.refNum = this.refNum;

% [EOF]

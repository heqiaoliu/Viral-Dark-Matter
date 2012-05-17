function Hd = dispatch(this)
%DISPATCH   Return the lwdfilt.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:48:21 $

Hd = lwdfilt.tf(this.Gain);

Hd.refnum = this.refGain;

% [EOF]

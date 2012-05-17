function Hd = todf2sos(this)
%TODF2SOS   Convert to a DF2SOS.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:55:01 $

[sos, g] = tf2sos(this.Numerator, this.Denominator);

Hd = dfilt.df2sos(sos, g);

% [EOF]

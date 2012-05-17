function Hd = todf1sos(this)
%TODF1SOS   Convert to a DF1SOS.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:54:59 $

[sos, g] = tf2sos(this.Numerator, this.Denominator);

Hd = dfilt.df1sos(sos, g);

% [EOF]

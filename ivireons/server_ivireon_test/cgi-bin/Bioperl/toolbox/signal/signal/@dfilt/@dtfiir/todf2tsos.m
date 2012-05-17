function Hd = todf2tsos(this)
%TODF2TSOS   Convert to a DF2TSOS.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:55:02 $

[sos, g] = tf2sos(this.Numerator, this.Denominator);

Hd = dfilt.df2tsos(sos, g);

% [EOF]
